$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('friends', 'show')) {
  	COPO.utility.setActivePage('friends')
    COPO.utility.gonFix();
    COPO.maps.initMap();
    COPO.maps.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
    gon.checkins.length ? COPO.maps.initMarkers(gon.checkins) : $('#map-overlay').removeClass('hide');
  }
});
