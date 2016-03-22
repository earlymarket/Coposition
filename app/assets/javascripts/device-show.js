$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
    google.charts.setOnLoadCallback(COPO.charts.drawChart);
    google.charts.setOnLoadCallback(COPO.charts.drawTable);

    $('li.tab').on('click', function() {
      var tab = event.target.innerText
      setTimeout(function(event) {
        if (tab ==='CHART'){
          COPO.charts.drawChart(); //makes chart fit page
        } else {
          map.invalidateSize(); // makes map fit page
        }
      }, 100);
    });


  }
});


