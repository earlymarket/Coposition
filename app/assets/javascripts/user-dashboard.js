$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {

    COPO.maps.initMap();
    map.fitWorld();
    google.charts.setOnLoadCallback(function() {
       COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
