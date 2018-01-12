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
      window.COPO.editCheckin.init();
      if (!U.mobileCheck()) {
        Materialize.toast('Right click map to check-in', 3000)
      }
    }

    $("#deleteDevice").on("click", () => {
      swal({
        title: "Enter device name to delete this device and check-ins",
        content: {
         element: "input",
         attributes: {
           placeholder: "Enter your device name",
           id: "deviceName",
           type: "text",
         },
       },
        buttons: {
          cancel: {
            text: "Cancel",
            visible: true,
          },
          confirm: {
            text: "Confirm",
            closeModal: false
          }
        }
      })
      .then(deviceName => {
        if (!deviceName) return
        let match = gon.devices.find((device) => device.name === deviceName)
        if (match) {
          $.ajax({
            url: '/users/' + gon.current_user_id + '/devices/' + gon.device,
            type: 'DELETE',
          }).then(swal.closeModal);
        } else {
          swal("Incorrect device name", "The device name you entered did not match", "error");
        }
      })
    })

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
        $('.checkins_view').val(true)
        M.initMarkers(gon.checkins, gon.total)
      } else {
        M.initMarkers(gon.cities, gon.total, true);
      }
    }
  }
});
