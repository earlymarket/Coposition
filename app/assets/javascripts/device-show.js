$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
    //google.charts.setOnLoadCallback(COPO.charts.drawBarChart);
    //google.charts.setOnLoadCallback(COPO.charts.drawTable);

    $('li.tab').on('click', function() {
      var tab = event.target.innerText
      setTimeout(function(event) {
        if (tab ==='CHART'){
          COPO.charts.drawBarChart(gon.checkins);
          COPO.charts.drawTable(gon.checkins);
        } else {
          map.invalidateSize();
        }
      });
    });

    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.checkins);
      COPO.charts.drawTable(gon.checkins);
     });

  }
});
