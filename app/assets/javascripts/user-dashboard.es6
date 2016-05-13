$(document).on('page:change', function () {
  if ($(".c-dashboards.a-show").length === 1) {
    const M  = window.COPO.maps;
    const U  = window.COPO.utility;
    const SL = window.COPO.slides;
    U.gonFix();
    M.initMap();
    M.initControls();
    COPO.smooch.initSmooch(gon.current_user.userinfo);

    // Persistent map feature declarations
    const SELF_MARKER = {
      hasCheckin () {
        return Boolean(gon.current_user.lastCheckin) === true
      },
      init () {
        if (this.hasCheckin()) {
          M.makeMapPin(gon.current_user, 'blue', {clickable: false}).addTo(map);
        } else if (!$('#map-overlay hide').length) {
          let whereAmI = `
          <blockquote>
            <h4>Where am I?</h4>
            Use the locate control in the top left to temporarily find your current location. Or check-in on a device of your own!
          </blockquote>`
          $('#map-wrapper').after(whereAmI);
        }
      }
    }
    // end of persistent declarations

    // Slide type declarations
    const FRIENDS_SLIDE = {
      hasFriends () {
        return gon.friends.length > 0;
      },
      hasFriendsWithCheckins () {
        return this.hasFriends() && gon.friends.filter(friend => friend.lastCheckin).length > 0;
      },
      layers () {
        let clusters = M.arrayToCluster(gon.friends, M.makeMapPin);
        clusters.eachLayer((marker) => {
          marker.on('click', function (e) {
            M.panAndW3w.call(this, e)
          });
          marker.on('mouseover', (e) => {
            if(!marker._popup) {
              this.addPopup(marker);
            }
            COPO.maps.w3w.setCoordinates(e);
            marker.openPopup();
          });
        });
        return clusters;
      },
      addPopup (marker) {
        let user    = marker.options.user;
        let name    = U.friendsName(user);
        let date    = new Date(marker.options.lastCheckin.created_at).toUTCString();
        let address = U.commaToNewline(marker.options.lastCheckin.address) || marker.options.lastCheckin.fogged_area;
        let content = `
        <h2>${ name } <a href="./friends/${user.slug}" title="Device info">
          <i class="material-icons tiny">perm_device_information</i>
          </a></h2>
        <div class="address">${ address }</div>
        Checked in: ${ date }`
        marker.bindPopup(content, { offset: [0, -38] } );
      },
      bounds () {
        return L.latLngBounds(
          _.compact(gon.friends.map(friend => friend.lastCheckin))
          .map(friend => L.latLng(friend.lat, friend.lng))
        )
      },
      status: `Your friend's check-ins <a href='./friends'>(more details)</a>`,
      init (caller) {
        if (this.hasFriendsWithCheckins()) {
          caller.slides.push({
            status:   this.status,
            layers: this.layers(),
            bounds:   this.bounds()
          });
        }
      }
    }
    const MONTHLY_SLIDE = {
      hasCheckins () {
        return gon.months_checkins.length > 0
      },
      layers () {
        let checkins = [...gon.months_checkins];
        if(gon.current_user.lastCheckin) {
          checkins = checkins.filter(checkin => checkin.id !== gon.current_user.lastCheckin.id);
        }
        let clusters = M.arrayToCluster(checkins, M.makeMarker)
        clusters.eachLayer((marker) => {
          marker.on('click', function (e) {
            M.panAndW3w.call(this, e)
          });
        });
        return clusters;
      },
      bounds () {
        return L.latLngBounds(
          gon.months_checkins.map(checkin => L.latLng(checkin.lat, checkin.lng))
        );
      },
      status: `Your last month's check-ins <a href='./devices'>(more details)</a>`,
      init (caller) {
        if (this.hasCheckins()) {
          caller.slides.push({
            status:   this.status,
            layers: this.layers(),
            bounds:   this.bounds()
          });
        }
      }
    }
    // end of slide type declarations
    const DECK = {
      // slides are the states that are cycled through
      // slideTypes are the objects we initialize in DECK.init()
      slides: [],
      slideTypes: [FRIENDS_SLIDE, MONTHLY_SLIDE],
      persistent: [SELF_MARKER],
      pause () {
        this.paused = true;
      },
      unpause () {
        this.paused = false;
      },
      hasSlides () {
        return this.slides.length > 0;
      },
      showNullState () {
        $('#map-overlay').removeClass('hide');
      },
      initHandler () {
        if (!this.hasSlides()) return;
        this.slideIndex = 0;
        this.activeLayer = L.layerGroup().addTo(map);
        map.once('ready', this.next.bind(this));
        map.on('mouseover', this.pause.bind(this));
        map.on('mouseout', this.unpause.bind(this));
        $(document).on('timer:ping', this.next.bind(this) )
        // Cleanup
        $(document).one('page:before-unload', function () {
          $(document).off('timer:ping');
        });
      },
      next() {
        if(this.paused) return;
        let currentSlide = this.slides[this.slideIndex];
        this.activeLayer.clearLayers().addLayer(currentSlide.layers);
        if (currentSlide.bounds.isValid()) {
          window.map.fitBounds(currentSlide.bounds, {padding: [40, 40]})
        };
        $('#map-status').html(currentSlide.status);
        if (++this.slideIndex >= this.slides.length) {
          this.slideIndex = 0
        };
      },
      init () {
        this.paused = false;
        this.persistent.forEach(feature => feature.init(this));
        this.slideTypes.forEach(slide => slide.init(this));
        this.initHandler();
        if (!this.hasSlides() && !gon.current_user.lastCheckin) this.showNullState();
      }
    };
    const timer = timer || new SL.Timer(5000);
    DECK.init();
    google.charts.setOnLoadCallback(() => {COPO.charts.drawBarChart(gon.weeks_checkins, '270')});
    $(window).resize(() => {COPO.charts.drawBarChart(gon.weeks_checkins, '270')});
  }
});
