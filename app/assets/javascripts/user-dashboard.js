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
          var user = this.options.user;
          user.username = COPO.utility.friendsName(user);
          marker.bindPopup(Mustache.render(
            'Visit <a href="./friends/{{ slug }}">{{username}}</a>\'s page for more info.',
             user),
            {offset: [0, -38]}
          );
        }
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
