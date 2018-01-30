$(document).on('page:change', function () {
  if (window.COPO.utility.currentPage('dashboards', 'show')) {
    const M  = window.COPO.maps;
    const U  = window.COPO.utility;
    const SL = window.COPO.slides;
    U.initAppcues(gon.current_user.userinfo)
    U.gonFix();
    M.initMap();
    M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);

    $('#checkin_id').keypress((e) => {
      if (e.which === 13) checkinSearch()
    })

    $('#find-checkin').on('click', checkinSearch)

    function checkinSearch () {
      let userId = gon.current_user.userinfo.id
      let checkinId = $('#checkin_id').val()
      window.location = `/users/${userId}/devices/nil/checkins/${checkinId}`
    }

    // Persistent map feature declarations
    const SELF_MARKER = {
      hasCheckin () {
        return Boolean(gon.current_user.lastCheckin) === true
      },
      init (caller) {
        if (this.hasCheckin()) {
          M.makeMapPin(gon.current_user, 'blue', {clickable: false}).addTo(map);
          caller.hasContent = true;
        } else if (caller.hasContent) {
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
      bounds () {
        return L.latLngBounds(
          _.compact(gon.friends.map(friend => friend.lastCheckin))
          .map(friend => L.latLng(friend.lat, friend.lng))
        )
      },
      status: `Your friend's check-ins. <a class='btn-flat blue-text' href='./friends'>view friends</a>`,
      init (caller) {
        if (this.hasFriendsWithCheckins()) {
          caller.slides.push({
            status:   this.status,
            layers:   M.bindFriendMarkers(gon.friends),
            bounds:   this.bounds()
          });
          caller.hasContent = true;
        } else if (this.hasFriends() && caller.hasContent && !$('#whereFriends').length) {
          let whereAreMyFriends = `
          <blockquote id="whereFriends">
            <h4>Where are my friends?</h4>
            You have ${gon.friends.length} ${U.pluralize('friend', gon.friends.length)} signed up but they haven't checked in yet
            (or they haven't shared their location with you).
            They'll appear on the map once they share their location.
          </blockquote>`
          $('#map-wrapper').after(whereAreMyFriends);
        } else if (caller.hasContent && !$('#whyEmpty').length) {
          let getSomeFriends = `
          <blockquote id="whyEmpty">
            <h4>Why is this map empty?</h4>
            You haven't got any friends yet, check if you have any friend requests or add a new friend from the friends page.
            They'll appear on the map once they share their location.
          </blockquote>`
          $('#map-wrapper').after(getSomeFriends);
        }
      }
    }
    const DEVICE_SLIDE = {
      hasCheckins () {
        return gon.device_checkins.length > 0
      },
      layers () {
        let checkins = [...gon.device_checkins];
        let clusters = M.checkinsToLayer(checkins, M.makeDeviceMarker)
        clusters.eachLayer((marker) => {
          marker.on('click', function (e) {
            let checkin = this.options.checkin;
            if (!marker._popup) {
              var template = COPO.maps.buildCheckinPopup(checkin, marker)
              marker.bindPopup(L.Util.template(template, checkin));
              marker.openPopup();
            }
          });
        });
        return clusters;
      },
      bounds () {
        return L.latLngBounds(
          gon.device_checkins.map(checkin => L.latLng(checkin.lat, checkin.lng))
        );
      },
      status: `Your devices most recent check-ins. <a class='btn-flat blue-text' href='./devices'>view devices</a>`,
      init (caller) {
        if (this.hasCheckins()) {
          caller.slides.push({
            status:   this.status,
            layers: this.layers(),
            bounds:   this.bounds()
          });
          caller.hasContent = true;
        }
      }
    }
    // end of slide type declarations
    const DECK = {
      // slides are the states that are cycled through
      // slideTypes are the objects we initialize in DECK.init()
      slides: [],
      slideTypes: [FRIENDS_SLIDE, DEVICE_SLIDE],
      hasContent: false,
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
      initTimerHandler () {
        if (!this.hasSlides()) return;
        this.slideIndex = 0;
        this.activeLayer = L.layerGroup().addTo(map);
        // Run this.next() once to populate the map
        map.once('ready', this.next.bind(this));
        map.on('mouseover', this.pause.bind(this));
        map.on('mouseout', this.unpause.bind(this));
        $(document).on('timer:ping', this.cycleNext.bind(this))
        // Cleanup
        $(document).one('turbolinks:before-render', function () {
          $(document).off('timer:ping');
        });
      },
      cycleNext () {
        // Seperating the "next" action from the one that gets triggered by the timer
        // This is so a user triggered "next" works even if cycling is paused
        if(this.paused) return;
        this.next.call(this);
      },
      next () {
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
        this.slideTypes.forEach(slide => slide.init(this));
        this.initTimerHandler();
        if (!this.hasContent) this.showNullState();
      }
    };
    const timer = new SL.Timer(5000);
    DECK.init();
    window.deck = DECK;
  }
});
