$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('devices', 'shared')) {
    COPO.maps.initMap()
    COPO.maps.initControls();
    var checkin = gon.checkin;
    var avatar, template, rendered;

    if(!checkin) {
      avatar = COPO.utility.avatar(gon.user.avatar, {class: 'left'});
      var friend = {
        name: COPO.utility.friendsName(gon.user),
        device: gon.device,
        avatar: avatar
       }
      template = $('#nullPopupTemplate').html();
      rendered = Mustache.render(template, friend);

      var popup = L.popup({'closeButton': false, 'closeOnClick': false})
        .setLatLng(new L.latLng([51.5073509, -0.1277583])) //hardcoded latlng for London
        .setContent(rendered)
        .openOn(map);
      map.on('ready', function(){
        map.panTo(popup.getLatLng());
      })
    } else {
      avatar = COPO.utility.avatar(gon.user.avatar);
      $.extend(checkin, {
        avatar: avatar,
        created_at: new Date(checkin.created_at).toUTCString(),
        address: checkin.address ? checkin.address.replace(/, /g, '\n') : checkin.city,
        device: gon.device,
        friend: COPO.utility.friendsName(gon.user)
      })

      template = $('#fullPopupTemplate').html();
      rendered = Mustache.render(template, checkin);

      map.setView([checkin.lat, checkin.lng], 12)
      var marker = L.marker([checkin.lat, checkin.lng], {
        icon: L.mapbox.marker.icon({
          'marker-size': 'large',
          'marker-symbol': 'marker',
          'marker-color': '#ff6900'
        })
      })
      .bindPopup(rendered, {maxWidth: 600})
      .addTo(map);

      marker.openPopup();

      coords = {
        latlng: new L.latLng([checkin.lat, checkin.lng])
      }
      COPO.maps.w3w.setCoordinates(coords);
    }
  }
});
