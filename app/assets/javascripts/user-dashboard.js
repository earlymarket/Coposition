$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {

    var M = COPO.maps
    M.initMap();
    M.initControls();

    M.makeMapPin(gon.current_user, 'blue').addTo(map);

    var markers = gon.friends.slice();
    var friendClusters = M.arrayToCluster(markers, M.makeMapPin);

    friendClusters.eachLayer(function(marker){
      marker.on('click', function(e) {
        map.panTo(this.getLatLng());
        COPO.maps.w3w.setCoordinates(e);
      })

      marker.on('mouseover', function(e){
        if(!marker._popup){
          let user = this.options.user;
          let name = COPO.utility.friendsName(user);
          let date = new Date(this.options.lastCheckin.created_at).toUTCString();
          let address = this.options.lastCheckin.address.replace(/, /g, '\n');
          address = address || this.options.lastCheckin.fogged_area;

          let content = `
          <h2><a href="./friends/${user.slug}">${ name }</a></h2>
          <div class="address">${ address }</div>
          Checked in on ${ date }`
          marker.bindPopup(content, { offset: [0, -38] } );
        }
        COPO.maps.w3w.setCoordinates(e);
        marker.openPopup();
      })
    })

    map.addLayer(friendClusters).fitBounds(friendClusters);

    google.charts.setOnLoadCallback(function() {
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
