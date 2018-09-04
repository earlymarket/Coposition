$(document).on('page:change', () => {
  if (window.COPO.utility.currentPage('devices', 'new')) {
    $.validator.setDefaults({
      ignore: []
    });

    $.validator.addMethod(
      "regex",
      function(value, element, regexp) {
          var re = new RegExp(regexp);
          return this.optional(element) || re.test(value);
      },
      "Device name must be between 4-20 characters, can only contain alphanumeric characters and underscores and must start with an alphabetic character."
    );

    // configure your validation

    $("#new_device").validate({
      onkeyup: false,
      rules: {
        "device[name]": {
          required: true,
          regex: /^([A-Za-z][A-Za-z0-9]*(?:_+[A-Za-z0-9])*){4,20}$/
        },
        "device[icon]": {
          required: true
        }
      },
      errorElement: "div",
      errorPlacement: function(error, element) {
        var placement = $(element).data("error");
        if (placement) {
          $(placement).append(error)
        } else {
          error.insertAfter(element);
        }
      },
      errorClass: "invalid",
      validClass: "valid"
    });

    COPO.utility.setActivePage('devices')
    const $CREATE_CHECKIN = $('#create_checkin');
    const $ADD_BUTTON = $('#add_button');
    const $PREVIEW = $('#preview');
    if ($CREATE_CHECKIN.prop('checked')) {
      navigator.geolocation.getCurrentPosition(showPosition, COPO.utility.geoLocationError);
    }

    $CREATE_CHECKIN.change(() => {
      if ($CREATE_CHECKIN.prop('checked')) {
        $ADD_BUTTON.addClass('disabled').prop('disabled', true);
        $PREVIEW.css('display', 'block');
        navigator.geolocation.getCurrentPosition(showPosition, COPO.utility.geoLocationError);
      } else {
        $PREVIEW.fadeOut("fast", () => $PREVIEW.addClass("hide"));
        $ADD_BUTTON.removeClass('disabled').prop('disabled', false);
        if (typeof map !== "undefined") {
          $(document).off('turbolinks:before-render', COPO.maps.removeMap);
          COPO.maps.removeMap();
        }
      }
    });

    function showPosition(position) {
      $ADD_BUTTON.removeClass("disabled").prop('disabled', false);
      $PREVIEW.removeClass("hide");

      const LOCATION = { lat: position.coords.latitude, lng: position.coords.longitude }
      updateLocation(LOCATION);

      COPO.maps.initMap({
        tileLayer: {
          continuousWorld: false,
          noWrap: true
        }
      });
      COPO.maps.initControls(['geocoder', 'w3w', 'layers']);
      const MARKER_OPTIONS = {
        icon: L.mapbox.marker.icon({ 'marker-symbol' : 'marker', 'marker-color' : '#ff6900' }),
        draggable: true
      }
      const MARKER = L.marker([LOCATION.lat, LOCATION.lng], MARKER_OPTIONS);
      MARKER.addTo(map);
      map.once('ready', () => map.setView(MARKER.getLatLng(), 16));
      MARKER.on('dragend', e => updateLocation(e.target.getLatLng()));

      function updateLocation(loc) {
        $('#coordinates').html(`Lat: ${loc.lat.toFixed(6)}<br />Lng: ${loc.lng.toFixed(6)}<br />`);
        const LATLON = `${loc.lng},${loc.lat}`;
        $('#location').attr("value", LATLON);
        $.get(
          `https://maps.googleapis.com/maps/api/geocode/json?latlng=${loc.lat},${loc.lng}&key=AIzaSyDqwD4k7HuZ1zlf3-un1qcbKnqknL9gt4c`)
        .done(function(data) {
          if(data.status!=='ZERO_RESULTS'){
            $('#coordinates').append(data.results[0].formatted_address.replace(/, /g, '\n'))
          }
        });
      }
    }

    $(document).one('turbolinks:before-render', function(){
      $CREATE_CHECKIN.off('change');
    })
  }
});
