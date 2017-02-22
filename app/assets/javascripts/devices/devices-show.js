$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1 || $(".c-devices.a-show").length === 1) {
    var page = $(".c-devices.a-show").length === 1 ? 'user' : 'friend'
    var fogged = false;
    var currentCoords;
    var U = window.COPO.utility;
    var M = window.COPO.maps;
    U.gonFix();
    M.initMap();
    M.initMarkers(gon.checkins, gon.total);
    M.initControls();
    COPO.datePicker.init();

    map.on('locationfound', onLocationFound);

    if (page === 'user') {
      map.on('contextmenu', function(e) {
        var coords = {
          lat: e.latlng.lat.toFixed(6),
          lng: e.latlng.lng.toFixed(6),
          checkinLink: U.createCheckinLink(e.latlng)
        };
        template = $('#createCheckinTmpl').html();
        var content = Mustache.render(template, coords);
        var popup = L.popup().setLatLng(e.latlng).setContent(content);
        popup.openOn(map);
      })

      map.on('popupopen', function(e) {
        var coords = e.popup.getLatLng()
        if($('#current-location').length) {
          $createCheckinLink = U.createCheckinLink(coords);
          $('#current-location').replaceWith($createCheckinLink);
        }
      })

      $('#checkinNow').on('click', function() {
        fogged = false;
        getLocation();
      })

      $('#checkinFoggedNow').on('click', function() {
        fogged = true;
        getLocation();
      })

      $('body').on('click', '.editable-wrapper.clickable', handleEditStart);

      function handleEditStart() {
        var $editable = $('.editable');
        M.mousePositionControlInit();
        $('.editable-wrapper').toggleClass('clickable');
        // make .editable, a contenteditable
        // select all the text to make it easier to edit
        $editable.attr('contenteditable', true);
        $editable.focus();
        document.execCommand('selectAll', false, null);
        setEditableListeners($editable)
      }

      function setEditableListeners($editable) {
        var original = $editable.text();

        // mousing over the map shows crosshair to quickly set latlng
        $('#map').toggleClass('crosshair');
        map.on('click', function(e) {
          handleMapClick($editable, e);
        });

        // if they click the popup, stop editing
        $('.leaflet-popup').on('click', function (e) {
          if(e.target.className !== 'editable') {
            handleCoordsEdited(original, $editable);
          }
        });

        // if they hit enter or esc, stop editing
        $editable.on('keydown', function (e) {
          if(e.which === 27 || e.which === 13 ) {
            handleCoordsEdited(original, $editable);
          }
        });

        // if they click another marker, remove all the listeners
        COPO.maps.allMarkers.eachLayer(function(marker) {
          marker.on('click', function(e) {
            if($editable.attr('contenteditable')) {
              handleEditEnd($editable);
            }
          });
        });
      }

      function handleCoordsEdited(original, $editable) {
        var coords = $editable.text().split(",").map(parseFloat);
        if(original !== $editable.text() && coords.length === 2 && coords.every(U.validateLatLng)) {
          var url = $editable.data('url');
          var data = { checkin: { lat: coords[0], lng: coords[1]} }
          putUpdateCheckin(url, data);
        } else {
          // reverse the edit
          $editable.text(original);
        }
        handleEditEnd($editable);
      }

      function handleMapClick($editable, e) {
        var confirmText = "Are you sure? Click ok to reposition check-in to new coordinates (";
            confirmText += e.latlng.lat.toFixed(6) + ", " + e.latlng.lng.toFixed(6) + ").";
        if (confirm(confirmText)) {
          var data = { checkin: {lat: e.latlng.lat, lng: e.latlng.lng} }
          putUpdateCheckin($editable.data('url'), data);
        }
        handleEditEnd($editable);
      }

      function putUpdateCheckin(url, data) {
        $.ajax({
          dataType: 'json',
          url: url,
          type: 'PUT',
          data: data
        })
        .done(updateCheckin)
        .fail(function (error) {
          console.log('Error updating checkin:', error);
        })
      }

      function updateCheckin(response) {
        // tries to find the checkin in gon and update it with the response
        checkin = _.find(gon.checkins, _.matchesProperty('id',response.id));
        checkin.lat = response.lat;
        checkin.lng = response.lng;
        checkin.edited = response.edited;
        checkin.lastEdited = true;
        checkin.address = response.address;
        checkin.fogged_city = response.fogged_city;
        // delete the localDate so we generate fresh timezone data
        delete checkin.localDate;
        M.refreshMarkers(gon.checkins);
      }

      function handleEditEnd($editable) {
        map.removeControl(COPO.maps.mousePositionControl);
        $('#map').toggleClass('crosshair');
        $editable.removeAttr('contenteditable');
        U.deselect();
        $('.editable-wrapper').toggleClass('clickable');
        unsetEditableListeners($editable)
      }

      function unsetEditableListeners($editable) {
        map.off('click');
        $('.leaflet-popup').off('click');
        $editable.off('keydown');
      }

    }

    function postLocation(position) {
      $.ajax({
        url: '/users/'+gon.current_user_id+'/devices/'+gon.device+'/checkins/',
        type: 'POST',
        dataType: 'script',
        data: { checkin: { lat: position.coords.latitude, lng: position.coords.longitude, fogged: fogged } }
      });
    }

    function getLocation(fogged) {
      if(currentCoords) {
        var position = { coords: { latitude: currentCoords.lat, longitude: currentCoords.lng } }
        postLocation(position)
      } else {
        navigator.geolocation.getCurrentPosition(postLocation, U.geoLocationError, { timeout: 5000 });
      }
    }

    function onLocationFound(p) {
      currentCoords = p.latlng;
    }
  }
});
