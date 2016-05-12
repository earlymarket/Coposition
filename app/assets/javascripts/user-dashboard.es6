$(document).on('page:change', function () {
  if ($(".c-dashboards.a-show").length === 1) {
    const M = COPO.maps;
    const U = COPO.utility;
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
        console.log('init self marker');
        console.log('User has made a checkin: ' + this.hasCheckin());
        if (this.hasCheckin()) {
          M.makeMapPin(gon.current_user, 'blue', {clickable: false}).addTo(map);
        } else if ($('#map-overlay hide').length) {
          let whereAmI = `
          <blockquote>
            <h4>Where am I?</h4>
            Use the locate control in the top left to temporarily find your current location. Or check-in on a device of your own!
          </blockquote>`
          $('#map-status').after(whereAmI);
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
        console.log('init friends slide');
        console.log('User has friends: ' + this.hasFriends());
        console.log('User has friends with checkins: ' + this.hasFriendsWithCheckins());
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
        if(!gon.current_user.lastCheckin) {
          return M.arrayToCluster(gon.months_checkins, M.makeMarker);
        } else {
          let checkins = [...gon.months_checkins];
          checkins = checkins.filter(checkin => checkin.id !== gon.current_user.lastCheckin.id);
          return M.arrayToCluster(checkins, M.makeMarker);
        }
      },
      bounds () {
        return L.latLngBounds(
          gon.months_checkins.map(checkin => L.latLng(checkin.lat, checkin.lng))
        );
      },
      status: `Your last month's check-ins <a href='./devices'>(more details)</a>`,
      init (caller) {
        console.log('init monthly slide');
        console.log('User had checkins in the last month: ' + this.hasCheckins())
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
      hasSlides () {
        return this.slides.length > 0;
      },
      showNullState () {
        $('#map-overlay').removeClass('hide');
      },
      initTimer () {
        if (!this.hasSlides()) return;
        this.slideIndex = 0;
        this.activeLayer = L.layerGroup().addTo(map);
        window.map.once ('ready', this.next.bind(this));
        this.slideInterval = setInterval(this.next.bind(this), 1000 * 5);
        window.map.on ('mouseover', (e, undefined) => {
          clearInterval (this.slideInterval);
          this.slideInterval = undefined;
        })
        map.on('mouseout', () => {
          if (!this.slideInterval) this.slideInterval = setInterval(this.next.bind(this), 1000 * 5)
        })
        // Cleanup
        $(document).on('page:before-unload', () => {
          if (this.slideInterval) clearInterval(this.slideInterval);
        })
      },
      next() {
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
        this.persistent.forEach(feature => feature.init(this));
        this.slideTypes.forEach(slide => slide.init(this));
        this.initTimer();
        if (!this.hasSlides() && !gon.current_user.lastCheckin) this.showNullState();
        console.log('Slide deck init finished!');
      }
    };
    DECK.init();
    google.charts.setOnLoadCallback(() => {COPO.charts.drawBarChart(gon.weeks_checkins, '270')});
    $(window).resize(() => {COPO.charts.drawBarChart(gon.weeks_checkins, '270')});
  }
});
