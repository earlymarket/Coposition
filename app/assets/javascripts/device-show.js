$(document).on('ready page:change', function() {
  if ($(".c-devices.a-show").length === 0) {
    return;
  } else {
  //page specific code

  map.addControl(L.mapbox.geocoderControl('mapbox.places'));
  var lc = L.control.locate({
    follow: false,
    setView: false,
    markerClass: L.marker,
    markerStyle: {
      icon: L.mapbox.marker.icon({
        'marker-size': 'large',
        'marker-symbol': 'star',
        'marker-color': '#01579B',
      }),
      riseOnHover: true,
    },
    strings: {
      title: 'Your current location',
      popup: 'Your current location within {distance} {unit}.<br><a href="#" id="current-location">Create check-in here</a>',
    },

  }).addTo(map);
  lc.stop();
  lc.start();

  Copo.refreshMarkers = function(){
    Copo.markers.clearLayers();
    Copo.renderMarkers();
  }

  Copo.renderMarkers = function(){
    Copo.markers = new L.MarkerClusterGroup();
    var checkins = Copo.checkins;
      for (var i = 0; i < checkins.length; i++) {
        var checkin = checkins[i];
        var marker = L.marker(new L.LatLng(checkin.lat, checkin.lng), {
          icon: L.mapbox.marker.icon({
            'marker-symbol': 'heliport',
            'marker-color': '#ff6900',
          }),
          title: 'ID: ' + checkin.id,
          alt: 'ID: ' + checkin.id
        });

        var checkinDate = new Date(checkin.created_at).toUTCString()

        template = '<h3>ID: {id}</h3>'
        template += '<ul>'
        template += '<li>Created on: '+ checkinDate + '</li>'
        template += '<li>Latitude: {lat}</li>'
        template += '<li>Longitude: {lng}</li>'
        template += '<li>Address: ' + (checkin.address || checkin.fogged_area) + '</li>'
        template += '<li>Fogged status: {fogged}</li>'
        if(checkin.fogged){
          template += '<li>Fogged address: {fogged_area}</li>'
        }
        template += '</ul>'

        marker.bindPopup(L.Util.template(template, checkin))

        marker.on('click', function() {
          map.panTo(this.getLatLng());
        });

        Copo.markers.addLayer(marker);
      }

    map.addLayer(Copo.markers);
  }

  map.on('ready', function() {
    Copo.renderMarkers();
    map.fitBounds(Copo.markers.getBounds());
  });

  }
});

