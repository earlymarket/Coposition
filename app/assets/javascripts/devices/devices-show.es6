$(document).on('page:change', function() {
  var U = window.COPO.utility;
  if (U.currentPage('friends', 'show_device') || U.currentPage('devices', 'show') || U.currentPage('checkins', 'index')) {
    var fogged = false;
    var currentCoords;
    var M = window.COPO.maps;
    U.gonFix();
    M.initMap();
    initMarkers();
    var controls = ['geocoder', 'locate', 'w3w', 'fullscreen', 'path']
    U.currentPage('friends', 'show_device') ? controls.push('layers') : controls.push('cities', 'layers')
    M.initControls(controls);
    COPO.datePicker.init();

    map.on('locationfound', onLocationFound);

    if (!U.currentPage('friends', 'show_device')) {
      U.setActivePage('devices')
      window.COPO.editCheckin.init();
    } else {
      U.setActivePage('friends')
    }

    if (U.currentPage('devices', 'show')) {
      $('.modal-trigger').modal();
      M.createCheckinPopup();
      M.rightClickListener();
      M.checkinNowListeners(getLocation);
    }

    function postLocation(position) {
      $.ajax({
        url: '/users/' + gon.current_user_id + '/devices/' + gon.device + '/checkins/',
        type: 'POST',
        dataType: 'script',
        data: { checkin: { lat: position.coords.latitude, lng: position.coords.longitude, fogged: fogged } }
      });
    }

    function getLocation(checkinFogged) {
      fogged = checkinFogged;
      if (currentCoords) {
        var position = { coords: { latitude: currentCoords.lat, longitude: currentCoords.lng } }
        postLocation(position)
      } else {
        navigator.geolocation.getCurrentPosition(postLocation, U.geoLocationError, { timeout: 5000 });
      }
    }

    function onLocationFound(p) {
      currentCoords = p.latlng;
    }

    function initMarkers() {
      if (gon.checkin || U.currentPage('friends', 'show_device') || gon.checkins_view) {
        M.initMarkers(gon.checkins, gon.total)
      } else {
        M.initMarkers(gon.cities, gon.total, true);
      }
    }
  }
});
