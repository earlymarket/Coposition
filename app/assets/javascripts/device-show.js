$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
    google.charts.setOnLoadCallback(COPO.charts.drawChart);
    google.charts.setOnLoadCallback(COPO.charts.drawTable);

    var timesClicked = 0;
    $('li.tab.map').on('click', function() {
      var tab = event.target.innerText
      timesClicked++;
      if (timesClicked>0) {
        $('li.tab').unbind('click');
      }
      setTimeout(function(event) {
        if (tab ==='CHART'){
          COPO.charts.drawChart();
        } else {
          map.invalidateSize();
        }
      }, 100);
    });


  }
});


