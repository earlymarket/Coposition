window.COPO = window.COPO || {};
window.COPO.editCheckin = {
  init() {
    $('body').on('click', '.editable-wrapper.clickable', function(e) {
      COPO.editCheckin.handleEditStart($(e.currentTarget).find(".editable"));
    });
  },

  handleEditStart($editable) {
    COPO.maps.mousePositionControlInit();
    $editable.parent('.editable-wrapper').toggleClass('clickable');

    // make .editable, a contenteditable
    $editable.attr('contenteditable', true);

    if ($editable.hasClass("date")) {
      // if user edits date input set datepicker and open
      var $input = COPO.editCheckin.setDatepicker($editable);
      // map.closePopup();
      $input.pickadate("open");
    } else {
      // select all the text to make it easier to edit
      $editable.focus();
      document.execCommand('selectAll', false, null);
      // mousing over the map shows crosshair to quickly set latlng
      $('#map').addClass('crosshair');
      map.on('click', function(e) {
        COPO.editCheckin.handleMapClick($editable, e);
      });
    }

    // setup other listeners
    COPO.editCheckin.setEditableListeners($editable);
  },

  setEditableListeners($editable) {
    var original = $editable.text();

    // if user clicks the popup, stop editing
    $('.leaflet-popup').on('click', function (e) {
      if (e.target.className !== 'editable') {
        COPO.editCheckin.handleEdited(original, $editable);
      }
    });

    // if user hits enter or esc, stop editing
    $editable.on('keydown', function (e) {
      if (e.which === 27 || e.which === 13 ) {
        COPO.editCheckin.handleEdited(original, $editable);
      }
    });

    // if user clicks another marker, remove all the listeners
    COPO.maps.allMarkers.eachLayer(function(marker) {
      marker.on('click', function(e) {
        COPO.editCheckin.handleEditEnd($editable);
      });
    });
  },

  setDatepicker($editable) {
    // let marker = COPO.maps.findMarker(
    //   $editable.parents(".leaflet-popup").find("#marker_id").val()
    // );

    // $editable.parents(".leaflet-popup-pane")
    return $("body").pickadate({
      selectMonths: true,
      selectYears: 15,
      closeOnSelect: true,
      onSet: function(context) {
        if ("select" in context) {
          if (this.get("value")) {
            let date = new Date($editable.text());
            let newDate = new Date(this.get("value"));

            date.setDate(newDate.getDate());
            date.setMonth(newDate.getMonth());
            date.setFullYear(newDate.getFullYear());

            // open marker popup back again and set new date
            // marker.openPopup();
            // $editable = $(".editable-wrapper.clickable > .editable.date");
            // COPO.editCheckin.setEditableListeners($editable);
            $editable.text(
              date.toDateString() + ' ' + date.toLocaleTimeString() + " UTC+0000"
            );

            // remove datepicker with respect to next one
            this.stop();
          }
        }
      }
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
    if (original !== $editable.text()) {
      var url = $editable.data('url');
      var data = { checkin: { created_at: $editable.text()} }
      COPO.editCheckin.putUpdateCheckin(url, data);
    } else {
      // reverse the edit
      $editable.text(original);
    }
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
    checkin = _.find(gon.checkins, _.matchesProperty('id', response.checkin.id));
    checkin.lat = response.checkin.lat;
    checkin.lng = response.checkin.lng;
    checkin.edited = response.checkin.edited;
    checkin.lastEdited = true;
    checkin.address = response.checkin.address;
    if (checkin.created_at !== response.checkin.created_at) {
      checkin.created_at = moment.utc(response.checkin.created_at).format("ddd MMM D YYYY HH:mm:ss") + ' UTC+0000';
      gon.checkins.sort(function(a, b) {
        a.created_at - b.created_at;
      });
    }
    // delete the localDate so we generate fresh timezone data
    delete checkin.localDate;
    COPO.maps.refreshMarkers(gon.checkins);
  },

  handleEditEnd($editable) {
    map.removeControl(COPO.maps.mousePositionControl);
    $('#map').removeClass('crosshair');
    $editable.removeAttr('contenteditable');
    COPO.utility.deselect();
    $editable.parent('.editable-wrapper').toggleClass('clickable');
    COPO.editCheckin.unsetEditableListeners($editable)
  },

  unsetEditableListeners($editable) {
    map.off('click');
    $('.leaflet-popup').off('click');
    $editable.off('keydown');
  },
}
