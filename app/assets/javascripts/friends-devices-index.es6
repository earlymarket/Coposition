$(document).on('page:change', function() {
  if ($(".c-friends.a-show").length === 1) {
    COPO.utility.gonFix();
    COPO.maps.initMap();
    COPO.maps.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
    gon.checkins.length ? COPO.maps.initMarkers(gon.checkins) : $('#map-overlay').removeClass('hide');
  }
});
