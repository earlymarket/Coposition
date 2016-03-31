window.COPO = window.COPO || {};
window.COPO.maps = {
  map: null,

  initMap: function(){
    L.mapbox.accessToken = 'pk.eyJ1IjoiZ2FyeXNpdSIsImEiOiJjaWxjZjN3MTMwMDZhdnNtMnhsYmh4N3lpIn0.RAGGQ0OaM81HVe0OiAKE0w';
    map = L.mapbox.map('map', 'mapbox.light', {maxZoom: 18} );
  },

  initMarkers: function(){
    map.once('ready', function() {
      COPO.maps.renderMarkers();
      COPO.maps.bindMarkerListeners();
      if(COPO.maps.markers.getLayers().length){
        map.fitBounds(COPO.maps.markers.getBounds())
      } else {
        map.once('locationfound', function(e) {
          map.panTo(e.latlng);
        })
      }
    });
  },

  queueRefresh: function(){
    map.once('zoomstart', function(e){
      map.removeEventListener('popupclose');
      COPO.maps.refreshMarkers();
    })
    map.once('popupclose', function(e){
      COPO.maps.refreshMarkers();
    })
  },

  refreshMarkers: function(){
    map.removeLayer(COPO.maps.markers);
    map.removeLayer(COPO.maps.last);
    COPO.maps.renderMarkers();
    COPO.maps.bindMarkerListeners();
  },

  renderMarkers: function(){
    COPO.maps.markers = new L.MarkerClusterGroup();
    COPO.maps.last = new L.MarkerClusterGroup();
    var checkins = gon.checkins;
      for (var i = 0; i < checkins.length; i++) {
        var checkin = checkins[i];
        var symbol = 'heliport'
        var color = '#ff6900'
        var status = ''
        if (i === 0) {
          symbol = 'star'
          color = '#47b8e0'
          status = ' - Most recent'
        }
        var marker = L.marker(new L.LatLng(checkin.lat, checkin.lng), {
          icon: L.mapbox.marker.icon({
            'marker-symbol': symbol,
            'marker-color': color,
          }),
          title: 'ID: ' + checkin.id + status,
          alt: 'ID: ' + checkin.id + status,
          checkin: checkin
        });

        if (i === 0) {
          COPO.maps.last.addLayer(marker);
        } else {
          COPO.maps.markers.addLayer(marker);
        }
      }
    map.addLayer(COPO.maps.last);
    map.addLayer(COPO.maps.markers);
  },

  bindMarkerListeners: function(){
    COPO.maps.markers.eachLayer(function(marker) {
      COPO.maps.markerClickListener(marker);
    })
    COPO.maps.last.eachLayer(function(marker) {
      COPO.maps.markerClickListener(marker);
    })
  },

  markerClickListener: function(marker) {
    marker.on('click', function(e) {
      checkin = this.options.checkin;
      $.get({
        url: "/users/"+gon.current_user_id+"/devices/"+checkin.device_id+"/checkins/"+checkin.id,
        dataType: "json"
      }).done(function(data) {
        template = COPO.maps.buildMarkerPopup(data);
        marker.bindPopup(L.Util.template(template, data));
        marker.openPopup();
      })
      map.panTo(this.getLatLng());
      COPO.maps.w3w.setCoordinates(e);
    });
  },

  buildMarkerPopup: function(checkin){
    var checkinDate = new Date(checkin.created_at).toUTCString()
    var foggedClass;
    checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';

    template = '<h3>ID: {id}</h3>'
    template += '<ul>'
    template += '<li>Created on: '+ checkinDate + '</li>'
    template += '<li>Latitude: {lat}</li>'
    template += '<li>Longitude: {lng}</li>'
    template += '<li>Address: ' + (checkin.address || checkin.fogged_area) + '</li>'
    if (checkin.fogged){
      template += '<li class="foggedAddress">Fogged address: ' + checkin.fogged_area + '</li>'
    }

    if ($(".c-devices.a-show").length === 1){
      template += '<li>'+ COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog')
      template += COPO.utility.deleteCheckinLink(checkin) + '</li>';
      template += '</ul>';
    }

    return template;
  },

  initControls: function(){
    map.addControl(L.mapbox.geocoderControl('mapbox.places',
      { position: 'topright',
        keepOpen: true
      }
    ));

    COPO.maps.w3w = new L.Control.w3w({apikey: '4AQOB5CT', position: 'topright'});
    COPO.maps.w3w.addTo(map);

    COPO.maps.lc = L.control.locate({
      follow: false,
      setView: false,
      markerClass: L.marker,
      markerStyle: {
        icon: L.mapbox.marker.icon({
          'marker-size': 'large',
          'marker-symbol': 'star',
          'marker-color': '#01579B'
        }),
        riseOnHover: true
      },
      strings: {
        title: 'Your current location',
        popup: 'Your current location within {distance} {unit}.<br><a href="#" id="current-location"></a>'
      }

    }).addTo(map);

  },

  popUpOpenListener: function(){
    map.on('popupopen', function(e){
      var coords = e.popup.getLatLng()
      if($('#current-location').length){

        var checkin = {
          'checkin[lat]': coords.lat.toFixed(6),
          'checkin[lng]': coords.lng.toFixed(6)
        }
        var checkinPath = location.pathname + '/checkins';
        checkinPath += '?'
        checkinPath += $.param(checkin)

        $createCheckinLink = COPO.utility.ujsLink('post', 'Create checkin here', checkinPath);
        $('#current-location').replaceWith($createCheckinLink);
      }
    })
  }

}

