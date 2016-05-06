$(document).on('page:change', function () {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.utility.gonFix();
    const M = COPO.maps;
    const U = COPO.utility;
    const SLIDE_LAYERS = [];
    M.initMap();
    M.initControls();

    // Add the user to the map with a special pin. Will persist while other layers cycle.
    if(gon.current_user.lastCheckin) {
      let user = $.extend({}, gon.current_user);
      M.makeMapPin(user, 'blue', {clickable: false}).addTo(map);
    }

    const FRIENDS = [...gon.friends];

    // --- init FRIENDS_CLUSTERS i.e. clustered markers of user's friend's last checkins ---
    const FRIENDS_CLUSTERS = M.arrayToCluster(FRIENDS, M.makeMapPin);

    function addFriendPopup (marker) {
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

    FRIENDS_CLUSTERS.eachLayer((marker) => {
      marker.on('click', function (e) {
        M.panAndW3w(e, this)
      });
      marker.on('mouseover', (e) => {
        if(!marker._popup) {
          addFriendPopup(marker);
        }
        COPO.maps.w3w.setCoordinates(e);
        marker.openPopup();
      })
    })

    // --- end FRIENDS_CLUSTERS init ---

    const FRIENDS_BOUNDS = (() =>
      L.latLngBounds(
        _.compact(
          FRIENDS.map(friend => friend.lastCheckin)
        )
        .map(friend => L.latLng(friend.lat, friend.lng))
      )
    )();

    SLIDE_LAYERS.push({
      status:   `Your friend's check-ins <a href='./friends'>(more details)</a>`,
      clusters: FRIENDS_CLUSTERS,
      bounds:   FRIENDS_BOUNDS
    });

    // --- init MONTH_CLUSTERS. The user's last month's checkins.

    const MONTHS_CHECKINS = [...gon.months_checkins];
    const MONTHS_CLUSTERS = M.arrayToCluster(MONTHS_CHECKINS, M.makeMarker);

    // --- end MONTH_CLUSTERS ---

    const MONTHS_BOUNDS = (() => L.latLngBounds(MONTHS_CHECKINS
      .map(checkin => L.latLng(checkin.lat, checkin.lng))
    )) ();

    SLIDE_LAYERS.push({
      status:   `Your last month's check-ins <a href='./devices'>(more details)</a>`,
      clusters: MONTHS_CLUSTERS,
      bounds:   MONTHS_BOUNDS
    });

    let slideIndex = 0;
    const ACTIVE_LAYER = L.layerGroup().addTo(map);
    function next() {
      let currentSlide = SLIDE_LAYERS[slideIndex];
      ACTIVE_LAYER.clearLayers().addLayer(currentSlide.clusters);
      if (currentSlide.bounds.isValid()) map.fitBounds(currentSlide.bounds, {padding: [40, 40]});
      $('#map-status').html(currentSlide.status);
      if (++slideIndex >= SLIDE_LAYERS.length) slideIndex = 0;
    }
    map.once ('ready', next);
    let slideInterval = setInterval(next, 1000 * 5);

    map.on ('mouseover', function (e, undefined) {
      clearInterval (slideInterval);
      slideInterval = undefined;
    })

    map.on('mouseout', function () {
      if (!slideInterval) {
        slideInterval = setInterval(next, 1000 * 5);
      }
    })

    google.charts.setOnLoadCallback(function () {
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function () {
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });

    // Cleanup
    $(document).on('page:before-unload', function () {
      if (slideInterval) clearInterval(slideInterval);
    })
  }
});
