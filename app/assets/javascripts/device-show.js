$(document).on('ready page:change', function() {
  if ($(".c-devices.a-show").length === 0) {
    return;
  } else {
    //page specific code

    map.on('ready', function() {
      COPO.maps.renderMarkers();
      map.fitBounds(COPO.maps.markers.getBounds());
      COPO.maps.initControls();
    });


    window.COPO = window.COPO || {};

    //map related functions

    window.COPO.maps = {

      refreshMarkers: function(){
        COPO.maps.markers.clearLayers();
        COPO.maps.renderMarkers();
      },

      renderMarkers: function(){
        COPO.maps.markers = new L.MarkerClusterGroup();
        var checkins = gon.checkins;;
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

            template = COPO.maps.buildMarkerPopup(checkin)
            marker.bindPopup(L.Util.template(template, checkin))

            marker.on('click', function() {
              map.panTo(this.getLatLng());
            });

            COPO.maps.markers.addLayer(marker);
          }

        map.addLayer(COPO.maps.markers);
      },

      initControls: function(){
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
      },

      buildMarkerPopup: function(checkin){
        var checkinDate = new Date(checkin.created_at).toUTCString()

        template = '<h3>ID: {id}</h3>'
        template += '<ul>'
        template += '<li>Created on: '+ checkinDate + '</li>'
        template += '<li>Latitude: {lat}</li>'
        template += '<li>Longitude: {lng}</li>'
        template += '<li>Address: ' + (checkin.address || checkin.fogged_area) + '</li>'
        template += '<li>Fogged status: '+ COPO.utility.ujsLink('put', COPO.utility.foggedIcon(checkin.fogged) , window.location.pathname + '/checkins/' + checkin.id ).attr('id', 'fog' + checkin.id).prop('outerHTML') +'</li>'

        if(checkin.fogged){
          template += '<li>Fogged address: {fogged_area}</li>'
        }
        template += '</ul>';

        return template;
      },

    }

  }
})

