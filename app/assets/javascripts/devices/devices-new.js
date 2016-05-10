/*
$(document).on('page:change', function() {
  if ($(".c-devices.a-new").length === 1) {

    $("#create_checkin").change(function(){
      if ($('#create_checkin').prop('checked')){
        $('#add_button').addClass('disabled');
        $('#add_button').prop('disabled', true);
        if($('#mapholder').length === 0){
          $('#new_device').after("<%= j (render partial: 'preview_map') %>");
          navigator.geolocation.getCurrentPosition(showPosition, error);
        }
      } else {
        $('#mapholder').fadeOut("fast", function(){$('#mapholder').remove();});
        $('#add_button').removeClass('disabled');
        $('#add_button').prop('disabled', false);
      }
    });

    function showPosition(position) {
      $('#add_button').removeClass("disabled");
      $('#add_button').prop('disabled', false);
      var latlon = position.coords.longitude + "," + position.coords.latitude;
      var img_url = "https://api.mapbox.com/v4/mapbox.light/pin-l("+latlon+")/"+latlon+",16/500x500@2x.png?access_token=pk.eyJ1IjoiZ2FyeXNpdSIsImEiOiJjaWxjZjN3MTMwMDZhdnNtMnhsYmh4N3lpIn0.RAGGQ0OaM81HVe0OiAKE0w"
      $('#mapholder').removeClass("hide");
      $('#mapholder').attr("src", img_url);
      $('#location').attr("value", latlon);
    }

    function error(err){
      Materialize.toast('Could not get location', 3000)
    }

  }
})
*/
