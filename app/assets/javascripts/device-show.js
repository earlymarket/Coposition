$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
  }
});


