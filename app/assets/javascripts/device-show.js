$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
    google.charts.setOnLoadCallback(COPO.charts.drawChart);
    google.charts.setOnLoadCallback(COPO.charts.drawTable);

    $('li.tab.map').on('click', function() {
      setTimeout(function() {
        map.invalidateSize();
      }, 100);
    })
    $('li.tab.chart').on('click', function() {
      setTimeout(function() {
        COPO.charts.drawChart();
      }, 100);
    })
  }
});


