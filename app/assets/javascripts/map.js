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
      if(COPO.maps.allMarkers.getLayers().length){
        map.fitBounds(COPO.maps.allMarkers.getBounds())
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
    COPO.maps.allMarkers = new L.MarkerClusterGroup();
    COPO.maps.markers = new L.MarkerClusterGroup();
    COPO.maps.last = new L.MarkerClusterGroup();
    var checkins = gon.checkins;
      for (var i = 0; i < checkins.length; i++) {
        var checkin = checkins[i]
        var markerObject = {
          icon: L.mapbox.marker.icon({ 'marker-symbol' : 'heliport', 'marker-color' : '#ff6900' }),
          title: 'ID: ' + checkin.id,
          alt: 'ID: ' + checkin.id,
          checkin: checkin
        }
        if (i === 0) {
          markerObject.icon = L.mapbox.marker.icon({ 'marker-symbol' : 'star', 'marker-color' : '#47b8e0' })
          markerObject.title = 'ID: ' + checkin.id + ' - Most recent'
        }
        var marker = L.marker(new L.LatLng(checkin.lat, checkin.lng), markerObject);
        COPO.maps.allMarkers.addLayer(marker);
        if (i === 0) {
          COPO.maps.last.addLayer(marker);
        } else {
          COPO.maps.markers.addLayer(marker);
        }
      }
    map.addLayer(COPO.maps.markers);
    map.addLayer(COPO.maps.last);
  },

  bindMarkerListeners: function(){
    COPO.maps.allMarkers.eachLayer(function(marker) {
      COPO.maps.markerClickListener(marker);
    })
  },

  markerClickListener: function(marker) {
    marker.on('click', function(e) {
      checkin = this.options.checkin;
      if(!marker._popup){
        template = COPO.maps.buildMarkerPopup(checkin);
        marker.bindPopup(L.Util.template(template, checkin));
        marker.openPopup();
      }
      if ($(".c-devices.a-show").length === 1){
        $.get({
          url: "/users/"+gon.current_user_id+"/devices/"+checkin.device_id+"/checkins/"+checkin.id,
          dataType: "json"
        }).done(function(data) {
          $geocodedAddress = '<li class="address">Address: ' + data.address + '</li>'
          $('.address').replaceWith($geocodedAddress);
        })
      }
      map.panTo(this.getLatLng());
      COPO.maps.w3w.setCoordinates(e);
    });
  },

  buildMarkerPopup: function(checkin){
    checkin.lat = checkin.lat.toFixed(6);
    checkin.lng = checkin.lng.toFixed(6);
    checkin.created_at = new Date(checkin.created_at).toUTCString();
    checkin.address = checkin.address || checkin.fogged_area;
    checkin.foggedAddress = function(){
    var foggedClass;
    checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
      if(checkin.fogged){
        return '<li>'+ COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog') + '</li>'
      }
     }
    checkin.foggle = COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog');
    checkin.deletebutton = COPO.utility.deleteCheckinLink(checkin);
    template = $('#markerPopupTmpl').html();
    template = Mustache.render(template, checkin);
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
        $createCheckinLink = COPO.maps.createCheckinLink(coords);
        $('#current-location').replaceWith($createCheckinLink);
      }
    })
  },

  rightClickListener: function(){
    map.on('contextmenu', function(e){
      var coords = e.latlng
      $createCheckinLink = COPO.maps.createCheckinLink(coords);
      var content = '<ul>'
      content += '<li>Latitude: ' + coords.lat.toFixed(6) + '</li>';
      content += '<li>Longitude: ' + coords.lng.toFixed(6) + '</li>';
      content += '<li><a href="#" id="current-location"></a></li></ul>'
      var popup = L.popup().setLatLng(e.latlng).setContent(content);
      popup.openOn(map);
      $('#current-location').replaceWith($createCheckinLink);
    })
  },

  createCheckinLink: function(coords){
    var checkin = {
      'checkin[lat]': coords.lat.toFixed(6),
      'checkin[lng]': coords.lng.toFixed(6)
    }
    var checkinPath = location.pathname + '/checkins?' + $.param(checkin);
    return COPO.utility.ujsLink('post', 'Create checkin here', checkinPath);
  }

}

