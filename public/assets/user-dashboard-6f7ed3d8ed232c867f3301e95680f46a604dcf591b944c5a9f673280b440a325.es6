$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.utility.gonFix();
    COPO.smooch.initSmooch(gon.current_user.userinfo);
    const M = COPO.maps
    const U = COPO.utility
    M.initMap();
    M.initControls();

    // Add the user to the map with a special pin. Will persist while other layers cycle.
    if(gon.current_user.lastCheckin) {
      let user = $.extend({}, gon.current_user)
      M.makeMapPin(user, 'blue', {clickable: false}).addTo(map);
    }

    const FRIENDS = [...gon.friends];

    // --- init FRIENDSCLUSTERS i.e. clustered markers of user's friend's last checkins ---
    const FRIENDSCLUSTERS = M.arrayToCluster(FRIENDS, M.makeMapPin);

    let addFriendPopup = function(marker){
      let user = marker.options.user;
      let name = U.friendsName(user);
      let date = new Date(marker.options.lastCheckin.created_at).toUTCString();
      let address = U.commaToNewline(marker.options.lastCheckin.address) || marker.options.lastCheckin.fogged_area;

      let content = `
      <h2>${ name } <a href="./friends/${user.slug}" title="Device info">
        <i class="material-icons tiny">perm_device_information</i>
        </a></h2>
      <div class="address">${ address }</div>
      Checked in: ${ date }`
      marker.bindPopup(content, { offset: [0, -38] } );
    }

    FRIENDSCLUSTERS.eachLayer(function(marker){
      marker.on('click', function(e) {
        map.panTo(this.getLatLng());
        COPO.maps.w3w.setCoordinates(e);
      })

      marker.on('mouseover', function(e){
        if(!marker._popup){
          addFriendPopup(marker);
        }
        COPO.maps.w3w.setCoordinates(e);
        marker.openPopup();
      })
    })

    // --- end FRIENDSCLUSTERS init ---

    const FRIENDSBOUNDS = function() {
      let friendsWithCheckins = _.compact(FRIENDS.map(friend => friend.lastCheckin));
      return L.latLngBounds(friendsWithCheckins.map(friend => L.latLng(friend.lat, friend.lng)))
    };

    // --- init MONTHCLUSTERS. The user's last month's checkins.

    const MONTHSCHECKINS = [...gon.months_checkins];
    const MONTHSCLUSTERS = M.arrayToCluster(MONTHSCHECKINS, M.makeMarker);

    // --- end MONTHCLUSTERS ---

    const MONTHSBOUNDS = function() {
      return L.latLngBounds(MONTHSCHECKINS.map(checkin => L.latLng(checkin.lat, checkin.lng)))
    };

    const LAYERS = [
      { status: `Your friend's check-ins <a href='./friends'>(more details)</a>`,
        clusters: FRIENDSCLUSTERS,
        bounds: FRIENDSBOUNDS},
      { status: `Your last month's check-ins <a href='./devices'>(more details)</a>`,
        clusters: MONTHSCLUSTERS,
        bounds: MONTHSBOUNDS}
    ];

    let slideIndex = 0;

    let layerGroup = L.layerGroup().addTo(map);
    function next() {
      let currentSlide = LAYERS[slideIndex];
      layerGroup.clearLayers().addLayer(currentSlide.clusters);
      map.fitBounds(currentSlide.bounds(), {padding: [40, 40]});
      $('#map-status').html(currentSlide.status);
      if(++slideIndex >= LAYERS.length) slideIndex = 0;
    }
    map.once('ready', next);
    let slideInterval = setInterval(next, 1000 * 5);

    map.on('mouseover', function(e, undefined){
      clearInterval(slideInterval);
      slideInterval = undefined;
    })

    map.on('mouseout', function(){
      if(!slideInterval){
        slideInterval = setInterval(next, 1000 * 5);
      }
    })

    google.charts.setOnLoadCallback(function() {
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });

    // Cleanup
    $(document).on('page:before-unload', function(){
      if(slideInterval) clearInterval(slideInterval);
      $(window).off("resize");
    })
  }
});
