$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
  }
});

