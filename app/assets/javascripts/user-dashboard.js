$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {

    var M = COPO.maps
    M.initMap();
    M.initControls();

    M.makeMapPin(gon.current_user, 'blue').addTo(map);

    var markers = gon.friends.slice();
    var friendClusters = M.arrayToCluster(markers, M.makeMapPin)

    map.addLayer(friendClusters).fitBounds(friendClusters);

    google.charts.setOnLoadCallback(function() {
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
