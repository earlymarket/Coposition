$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1 || $(".c-devices.a-show").length === 1) {
    var page = $(".c-devices.a-show").length === 1 ? 'user' : 'friend'
    var fogged = false;
    COPO.utility.gonFix();
    COPO.maps.initMap();
    COPO.maps.initMarkers(gon.checkins, gon.total);
    COPO.maps.initControls();
    var currentCoords;

    map.on('locationfound', onLocationFound);

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
        getLocation();
      })

      $('#checkinFoggedNow').on('click', function(){
        fogged = true;
        getLocation();
      })
    }

    function postLocation(position){
      $.ajax({
        url: '/users/'+gon.current_user_id+'/devices/'+gon.device+'/checkins/',
        type: 'POST',
        dataType: 'script',
        data: { checkin: { lat: position.coords.latitude, lng: position.coords.longitude, fogged: fogged } }
      });
    }

    function getLocation(fogged){
      if(currentCoords){
        var position = { coords: { latitude: currentCoords.lat, longitude: currentCoords.lng } }
        postLocation(position)
      } else {
        navigator.geolocation.getCurrentPosition(postLocation, COPO.utility.geoLocationError, { timeout: 5000 });
      }
    }

    function onLocationFound(p){
      currentCoords = p.latlng;
    }
  }
});
