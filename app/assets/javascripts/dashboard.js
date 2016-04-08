$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    google.charts.setOnLoadCallback(function() {
       COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
