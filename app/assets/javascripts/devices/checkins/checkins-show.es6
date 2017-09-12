$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('checkins', 'show')) {
    COPO.maps.initMap()
    COPO.maps.initControls();
    var checkin = gon.checkin;
    var avatar, template, rendered;

    avatar = COPO.utility.avatar(gon.user.avatar);
    let tempdata = { created_at: moment.utc(checkin.created_at).format("ddd MMM D YYYY HH:mm:ss") + ' UTC+0000' }
    var foggedClass;
    checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
    $.extend(checkin, {
      avatar: avatar,
      created_at: new Date(checkin.created_at).toUTCString(),
      address: checkin.address ? checkin.address.replace(/, /g, '\n') : checkin.city,
      device: gon.device,
      friend: COPO.utility.friendsName(gon.user),
      deletebutton: COPO.utility.deleteCheckinLink(checkin, 'inherit'),
      foggle: COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog'),
      inlineCoords: COPO.utility.renderInlineCoords(checkin),
      inlineDate: COPO.utility.renderInlineDate(checkin, tempdata)
    })

    template = $('#showPopupTemplate').html();
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

    let coords = {
      latlng: new L.latLng([checkin.lat, checkin.lng])
    }
    COPO.maps.w3w.setCoordinates(coords);
  }
});

// buildCheckinPopup(checkin, marker) {
//   let address = checkin.city;
//   if (checkin.address) {
//     address = COPO.utility.commaToNewline(checkin.address)
//   }
//   var checkinTemp = {
//     id: checkin.id,
//     lat: checkin.lat.toFixed(6),
//     lng: checkin.lng.toFixed(6),
//     created_at: moment.utc(checkin.created_at).format("ddd MMM D YYYY HH:mm:ss") + ' UTC+0000',
//     address: address,
//     marker: marker._leaflet_id
//   };

//   var foggedClass;
//   checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
//   checkinTemp.foggedAddress = function() {
//     if (checkin.fogged) {
//       return `<div class="foggedAddress"><h3 class="lined"><span class="lined-pad">Fogged Address</span></h3>
//               <li>${checkin.fogged_city}</li></div>`
//     }
//   }
//   checkinTemp.devicebutton = function() {
//     if (window.COPO.utility.currentPage('devices', 'index')) {
//       return `<a href="./devices/${checkin.device_id}" title="Device map">${checkin.device}</a>`
//     } else {
//       return `<a href="${window.location.pathname}/show_device?device_id=${checkin.device_id}" title="Device map">${checkin.device}</a>`
//     }
//   }
//   checkinTemp.edited = checkin.edited ? '(edited)' : ''
//   checkinTemp.inlineCoords = COPO.utility.renderInlineCoords(checkin);
//   checkinTemp.foggle = COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog');
//   checkinTemp.deletebutton = COPO.utility.deleteCheckinLink(checkin);
//   checkinTemp.inlineDate = COPO.utility.renderInlineDate(checkin, checkinTemp);
//   var template = $('#markerPopupTmpl').html();
//   return Mustache.render(template, checkinTemp);
// },

