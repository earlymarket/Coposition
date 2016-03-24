$(document).on('page:change', function() {
  if ($(".c-devices.a-shared").length === 1) {

    COPO.maps.initMap()
    COPO.maps.initControls();
    var checkin = gon.checkin;
    var avatarOptions = {
      width: 60,
      height: 60,
      crop: 'fill',
      radius: 'max',
      gravity: 'face:center',
      class: 'left'
    }

    var avatar = COPO.utility.avatar(gon.user.avatar.public_id, avatarOptions);

    if(!checkin) {
      var friend = {
        name: COPO.utility.friendsName(gon.user),
        device: gon.device,
        avatar: avatar
       }
      var template = $('#nullPopupTemplate').html();
      var rendered = Mustache.render(template, friend);

      var popup = L.popup()
        .setLatLng(new L.latLng([51.5073509, -0.1277583])) //hardcoded latlng for London
        .setContent(rendered)
        .openOn(map);
      map.on('ready', function(){
        map.panTo(popup.getLatLng());
      })
    } else {
      $.extend(checkin, {
        avatar: avatar,
        created_at: new Date(checkin.created_at).toUTCString(),
        address: checkin.address.replace(/, /g, '\n'),
        device: gon.device,
        friend: COPO.utility.friendsName(gon.user)
      })

      var template = $('#fullPopupTemplate').html();
      var rendered = Mustache.render(template, checkin);

      map.setView([checkin.lat, checkin.lng], 12)
      var marker = L.marker([checkin.lat, checkin.lng], {
        icon: L.mapbox.marker.icon({
          'marker-size': 'large',
          'marker-symbol': 'heliport',
          'marker-color': '#ff6900',
          'closeButton': false
        })
      })
      .bindPopup(rendered)
      .addTo(map);

      marker.openPopup();

      coords = {
        latlng: new L.latLng([checkin.lat, checkin.lng])
      }
      COPO.maps.w3w.setCoordinates(coords);
    }

  }
});
