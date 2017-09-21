$(document).on('page:change', function() {
  var U = window.COPO.utility;
  if (U.currentPage('checkins', 'index')) {
    var fogged = false;
    var currentCoords;
    var M = window.COPO.maps;
    U.gonFix();
    M.initMap();
    initMarkers();
    var controls = ['geocoder', 'locate', 'w3w', 'fullscreen', 'path']
    controls.push('cities', 'layers')
    M.initControls(controls);
    COPO.datePicker.init();

    map.on('locationfound', onLocationFound);

    if (page === 'user') {
      $('.modal-trigger').modal();
      window.COPO.editCheckin.init();
    }

    function initMarkers() {
      if (gon.checkin) {
        M.initMarkers(gon.checkins, gon.total)
      } else {
        M.initMarkers(gon.cities, gon.total, true);
      }
    }
  }
});
