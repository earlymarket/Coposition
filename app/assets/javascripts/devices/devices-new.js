$(document).on('page:change', function() {
  if ($(".c-devices.a-new").length === 1) {

    $("#create_checkin").change(function(){
      if ($('#create_checkin').prop('checked')){
        $('#add_button').addClass('disabled').prop('disabled', true);
        if($('#preview').hasClass("hide")){
          $('#preview').css('display', 'block')
          navigator.geolocation.getCurrentPosition(showPosition, COPO.utility.geoLocationError);
        }
      } else {
        $(document).off('page:before-unload')
        $('#preview').fadeOut("fast", function(){$('#preview').addClass("hide");});
        if(typeof map != "undefined"){
          map.remove();
        }
        $('#add_button').removeClass('disabled').prop('disabled', false);
      }
    });

    function showPosition(position) {
      $('#add_button').removeClass("disabled").prop('disabled', false);
      $('#preview').removeClass("hide");

      var location = { lat: position.coords.latitude, lng: position.coords.longitude }
      updateLocation(location);

      COPO.maps.initMap({
        tileLayer: {
          continuousWorld: false,
          noWrap: true
        }
      });
      COPO.maps.newDeviceMarker
      markerOptions = {
        icon: L.mapbox.marker.icon({ 'marker-symbol' : 'marker', 'marker-color' : '#ff6900' }),
        draggable: true
      }
      var marker = L.marker([position.coords.latitude, position.coords.longitude], markerOptions)
      marker.addTo(map);
      map.once('ready', function() {
        map.setView(marker.getLatLng(), 16)
      })
      marker.on('dragend', function(e) {
        updateLocation(e.target.getLatLng());
      })

      function updateLocation(loc){
        $('#coordinates').html('Latitude: ' + loc.lat.toFixed(6) + '<br />Longitude: ' + loc.lng.toFixed(6));
        var latlon = loc.lng + "," + loc.lat;
        $('#location').attr("value", latlon);
      }
    }
  }
})
