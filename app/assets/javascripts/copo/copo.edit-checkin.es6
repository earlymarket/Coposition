window.COPO = window.COPO || {};
window.COPO.editCheckin = {
  init() {
    $('body').on('click', '.editable-wrapper.clickable', COPO.editCheckin.handleEditStart);
  },

  handleEditStart() {
    var $editable = $('.editable');
    COPO.maps.mousePositionControlInit();
    $('.editable-wrapper').toggleClass('clickable');
    // make .editable, a contenteditable
    // select all the text to make it easier to edit
    $editable.attr('contenteditable', true);
    $editable.focus();
    document.execCommand('selectAll', false, null);
    COPO.editCheckin.setEditableListeners($editable)
  },

  setEditableListeners($editable) {
    var original = $editable.text();

    // mousing over the map shows crosshair to quickly set latlng
    $('#map').toggleClass('crosshair');
    map.on('click', function(e) {
      COPO.editCheckin.handleMapClick($editable, e);
    });

    // if they click the popup, stop editing
    $('.leaflet-popup').on('click', function (e) {
      if (e.target.className !== 'editable') {
        COPO.editCheckin.handleEdited(original, $editable);
      }
    });

    // if they hit enter or esc, stop editing
    $editable.on('keydown', function (e) {
      if (e.which === 27 || e.which === 13 ) {
        COPO.editCheckin.handleEdited(original, $editable);
      }
    });

    // if they click another marker, remove all the listeners
    COPO.maps.allMarkers.eachLayer(function(marker) {
      marker.on('click', function(e) {
        if ($editable.attr('contenteditable')) {
          COPO.editCheckin.handleEditEnd($editable);
        }
      });
    });
  },

  handleEdited(original, $editable) {
    if ($editable.hasClass("date")) {
      COPO.editCheckin.handleDateEdited(original, $editable);
    } else {
      COPO.editCheckin.handleCoordsEdited(original, $editable);
    }
  },

  handleDateEdited(original, $editable) {
    COPO.editCheckin.handleEditEnd($editable);
  },

  handleCoordsEdited(original, $editable) {
    var coords = $editable.text().split(",").map(parseFloat);
    if (original !== $editable.text() && coords.length === 2 && coords.every(COPO.utility.validateLatLng)) {
      var url = $editable.data('url');
      var data = { checkin: { lat: coords[0], lng: coords[1]} }
      COPO.editCheckin.putUpdateCheckin(url, data);
    } else {
      // reverse the edit
      $editable.text(original);
    }
    COPO.editCheckin.handleEditEnd($editable);
  },

  handleMapClick($editable, e) {
    var confirmText = "Are you sure? Click ok to reposition check-in to new coordinates (";
        confirmText += e.latlng.lat.toFixed(6) + ", " + e.latlng.lng.toFixed(6) + ").";
    if (confirm(confirmText)) {
      var data = { checkin: {lat: e.latlng.lat, lng: e.latlng.lng} }
      COPO.editCheckin.putUpdateCheckin($editable.data('url'), data);
    }
    COPO.editCheckin.handleEditEnd($editable);
  },

  putUpdateCheckin(url, data) {
    $.ajax({
      dataType: 'json',
      url: url,
      type: 'PUT',
      data: data
    })
    .done(COPO.editCheckin.updateCheckin)
    .fail(function (error) {
      console.log('Error updating checkin:', error);
    })
  },

  updateCheckin(response) {
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
    COPO.maps.refreshMarkers(gon.checkins);
  },

  handleEditEnd($editable) {
    map.removeControl(COPO.maps.mousePositionControl);
    $('#map').toggleClass('crosshair');
    $editable.removeAttr('contenteditable');
    COPO.utility.deselect();
    $('.editable-wrapper').toggleClass('clickable');
    COPO.editCheckin.unsetEditableListeners($editable)
  },

  unsetEditableListeners($editable) {
    map.off('click');
    $('.leaflet-popup').off('click');
    $editable.off('keydown');
  },
}
