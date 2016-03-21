$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    google.charts.setOnLoadCallback(COPO.charts.drawChart);
    google.charts.setOnLoadCallback(COPO.charts.drawTable);
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
  }
});


