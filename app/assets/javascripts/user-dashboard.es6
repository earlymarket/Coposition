$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.utility.gonFix();
    const M = COPO.maps
    const U = COPO.utility
    M.initMap();
    M.initControls();

    // Add the user to the map with a special pin. Will persist while other layers cycle.
    M.makeMapPin(gon.current_user, 'blue', {clickable: false}).addTo(map);

    const FRIENDS = [...gon.friends];

    // --- init FRIENDCLUSTERS i.e. clustered markers of user's friend's last checkins ---
    const FRIENDCLUSTERS = M.arrayToCluster(FRIENDS, M.makeMapPin);

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

    FRIENDCLUSTERS.eachLayer(function(marker){
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

    // --- end FRIENDCLUSTERS init ---

    // --- init MONTHCLUSTERS. The user's last month's checkins.

    const MONTHSCHECKINS = [...gon.months_checkins];
    const MONTHSCLUSTERS = M.arrayToCluster(MONTHSCHECKINS, M.makeMarker);

    // --- end MONTHCLUSTERS ---

    const LAYERS = [
      { status: "Your friend's check-ins",
        data: FRIENDCLUSTERS},
      { status: `Your last month's check-ins <a href='./devices'>(more details)</a>`,
        data: MONTHSCLUSTERS}
    ];

    let currentLayer = 0;

    let layerGroup = L.layerGroup().addTo(map);
    function next() {
      layerGroup.clearLayers().addLayer(LAYERS[currentLayer].data);
      map.fitBounds(LAYERS[currentLayer].data);
      $('#map-status').html(LAYERS[currentLayer].status);
      if(++currentLayer >= LAYERS.length) currentLayer = 0;
    }
    next();
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
    })
  }
});
