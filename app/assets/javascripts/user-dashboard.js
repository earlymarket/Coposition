$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.utility.gonFix();
    const M = COPO.maps
    M.initMap();
    M.initControls();

    M.makeMapPin(gon.current_user, 'blue', {clickable: false}).addTo(map);

    const MARKERS = gon.friends.slice();
    const FRIENDCLUSTERS = M.arrayToCluster(MARKERS, M.makeMapPin);

    FRIENDCLUSTERS.eachLayer(function(marker){
      marker.on('click', function(e) {
        map.panTo(this.getLatLng());
        COPO.maps.w3w.setCoordinates(e);
      })

      marker.on('mouseover', function(e){
        if(!marker._popup){
          let user = this.options.user;
          let name = COPO.utility.friendsName(user);
          let date = new Date(this.options.lastCheckin.created_at).toUTCString();
          let address = this.options.lastCheckin.address.replace(/, /g, '\n') || this.options.lastCheckin.fogged_area;

          let content = `
          <h2>${ name } <a href="./friends/${user.slug}"><i class="material-icons tiny">perm_device_information</i></a></h2>
          <div class="address">${ address }</div>
          Checked in: ${ date }`
          marker.bindPopup(content, { offset: [0, -38] } );
        }
        COPO.maps.w3w.setCoordinates(e);
        marker.openPopup();
      })
    })

    map.addLayer(FRIENDCLUSTERS).fitBounds(FRIENDCLUSTERS);

    google.charts.setOnLoadCallback(function() {
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
