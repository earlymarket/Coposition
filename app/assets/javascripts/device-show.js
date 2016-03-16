$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initControls();
    COPO.maps.popUpOpenListener();
  }
});


