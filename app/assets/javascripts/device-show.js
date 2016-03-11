$(document).on('ready page:change', function() {
  if ($(".c-devices.a-show").length === 0) {
    return;
  } else {
  //page specific code

  window.Copo = window.Copo || {};
  window.Copo.Maps = window.Copo.Maps || {};

  Copo.Maps.refreshMarkers = function(){
    Copo.Maps.markers.clearLayers();
    Copo.Maps.renderMarkers();
  }

  Copo.Maps.renderMarkers = function(){
    Copo.Maps.markers = new L.MarkerClusterGroup();
    var checkins = Copo.Maps.checkins;
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

        template = Copo.Maps.buildMarkerPopup(checkin)

        marker.bindPopup(L.Util.template(template, checkin))

        marker.on('click', function() {
          map.panTo(this.getLatLng());
        });

        Copo.Maps.markers.addLayer(marker);
      }

    map.addLayer(Copo.Maps.markers);
  }

  Copo.Maps.initControls = function(){
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
  }

  Copo.Maps.buildMarkerPopup = function(checkin){
    var checkinDate = new Date(checkin.created_at).toUTCString()

    template = '<h3>ID: {id}</h3>'
    template += '<ul>'
    template += '<li>Created on: '+ checkinDate + '</li>'
    template += '<li>Latitude: {lat}</li>'
    template += '<li>Longitude: {lng}</li>'
    template += '<li>Address: ' + (checkin.address || checkin.fogged_area) + '</li>'
    template += '<li>Fogged status: '+ Copo.Utility.foggedIcon(checkin.fogged) +'</li>'
    if(checkin.fogged){
      template += '<li>Fogged address: {fogged_area}</li>'
    }
    template += '</ul>';

    return template;
  }

  map.on('ready', function() {
    Copo.Maps.renderMarkers();
    map.fitBounds(Copo.Maps.markers.getBounds());
    Copo.Maps.initControls();
  });

  }
});

