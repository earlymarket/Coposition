$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1 || $(".c-devices.a-show").length === 1) {
    var page = $(".c-devices.a-show").length === 1 ? 'user' : 'friend'
    COPO.utility.gonFix();
    COPO.maps.initMap();
    COPO.maps.initMarkers(gon.checkins, gon.total);
    COPO.maps.initControls();

    if (page === 'user') {
      map.on('contextmenu', function(e){
        var coords = {
          lat: e.latlng.lat.toFixed(6),
          lng: e.latlng.lng.toFixed(6),
          checkinLink: COPO.utility.createCheckinLink(e.latlng)
        };
        template = $('#createCheckinTmpl').html();
        var content = Mustache.render(template, coords);
        var popup = L.popup().setLatLng(e.latlng).setContent(content);
        popup.openOn(map);
      })

      map.on('popupopen', function(e){
        var coords = e.popup.getLatLng()
        if($('#current-location').length){
          $createCheckinLink = COPO.utility.createCheckinLink(coords);
          $('#current-location').replaceWith($createCheckinLink);
        }
      })

      $('#checkinNow').on('click', function(){
        navigator.geolocation.getCurrentPosition(postLocation, COPO.utility.geoLocationError);
      })
    }

    function postLocation(position){
      $.ajax({
        url: `/users/${gon.current_user_id}/devices/${gon.device}/checkins/`,
        type: 'POST',
        dataType: 'script',
        data: { checkin: { lat: position.coords.latitude, lng: position.coords.longitude } }
      });
    }
  }
});

