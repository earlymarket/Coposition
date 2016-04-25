window.COPO = window.COPO || {};
window.COPO.maps = {
  initMap(customOptions){
    if(document.getElementById('map')._leaflet) return;
    L.mapbox.accessToken = 'pk.eyJ1IjoiZ2FyeXNpdSIsImEiOiJjaWxjZjN3MTMwMDZhdnNtMnhsYmh4N3lpIn0.RAGGQ0OaM81HVe0OiAKE0w';

    var defaultOptions = {
      maxZoom: 18,
      minZoom: 1
    }

    var options = $.extend(defaultOptions, customOptions);
    window.map = L.mapbox.map('map', 'mapbox.light', options );
  },

  initMarkers(){
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

  queueRefresh(){
    map.once('zoomstart', function(e){
      map.removeEventListener('popupclose');
      COPO.maps.refreshMarkers();
    })
    map.once('popupclose', function(e){
      COPO.maps.refreshMarkers();
    })
  },

  refreshMarkers(){
    map.removeLayer(COPO.maps.markers);
    map.removeLayer(COPO.maps.last);
    COPO.maps.renderMarkers();
    COPO.maps.bindMarkerListeners();
  },

  renderMarkers(){
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
          markerObject.icon = L.mapbox.marker.icon({ 'marker-symbol' : 'heliport', 'marker-color' : '#47b8e0' })
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

  bindMarkerListeners(){
    COPO.maps.allMarkers.eachLayer(function(marker) {
      COPO.maps.markerClickListener(marker);
    })
  },

  markerClickListener(marker) {
    marker.on('click', function(e) {
      var checkin = this.options.checkin;
      if(!marker._popup){
        var template = COPO.maps.buildMarkerPopup(checkin);
        marker.bindPopup(L.Util.template(template, checkin));
        marker.openPopup();
      }
      if ($(".c-devices.a-show").length === 1){
        $.get({
          url: "/users/"+gon.current_user_id+"/devices/"+checkin.device_id+"/checkins/"+checkin.id,
          dataType: "json"
        }).done(function(data) {
          var $geocodedAddress = '<li class="address">Address: ' + data.address + '</li>'
          $('.address').replaceWith($geocodedAddress);
          gon.checkins[_.indexOf(gon.checkins, checkin)] = data;
        })
      }
      map.panTo(this.getLatLng());
      COPO.maps.w3w.setCoordinates(e);
    });
  },

  buildMarkerPopup(checkin){
    var checkinTemp = {};
    checkinTemp.id = checkin.id
    checkinTemp.lat = checkin.lat.toFixed(6);
    checkinTemp.lng = checkin.lng.toFixed(6);
    checkinTemp.created_at = new Date(checkin.created_at).toUTCString();
    checkinTemp.address = checkin.address;
    var foggedClass;
    checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
    checkinTemp.foggedAddress = function(){
      if(checkin.fogged){
        return '<li class="foggedAddress">Fogged address: ' + checkin.fogged_area + '</li>'
      }
    }
    checkinTemp.foggle = COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog');
    checkinTemp.deletebutton = COPO.utility.deleteCheckinLink(checkin);
    var template = $('#markerPopupTmpl').html();
    return Mustache.render(template, checkinTemp);
  },

  initControls(){
    map.addControl(L.mapbox.geocoderControl('mapbox.places',
      { position: 'topright',
        keepOpen: true
      }
    ));

    COPO.maps.w3w = new L.Control.w3w({apikey: '4AQOB5CT', position: 'topright'});
    COPO.maps.w3w.addTo(map);

    COPO.maps.lc = L.control.locate({
      follow: false,
      setView: true,
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

  mapPinIcon(public_id, color){
    // The iconClass is a named Cloudinary transform
    // At the moment there are only two: 'map-pin' and
    // 'map-pin-blue'
    var iconClass;
    color === 'blue' ? iconClass = 'map-pin-blue' : iconClass = 'map-pin'
    return L.icon({
      iconUrl: $.cloudinary.url(public_id, {format: 'png', transformation: iconClass}),
      iconSize: [36,52],
      iconAnchor: [18,49]
    })
  },

  arrayToCluster: (markerArr, markerBuilderFn) => {
    if(!markerBuilderFn){
      return console.error('Marker building function undefined')
    }
    let cluster = markerArr.map(marker => markerBuilderFn(marker))
      .filter(marker => marker);
    return (new L.MarkerClusterGroup).addLayers(cluster)
  },

  makeMapPin(user, color, markerOptions){
    let checkin = user.lastCheckin
    if(checkin){
      let public_id = user.userinfo.avatar.public_id;
      let defaults = {
        icon: COPO.maps.mapPinIcon(public_id, color),
        riseOnHover: true,
        user: $.extend(true, {}, user.userinfo),
        lastCheckin: checkin
      }
      markerOptions = $.extend({}, defaults, markerOptions)
      return L.marker([checkin.lat, checkin.lng], markerOptions)
    } else {
      return false
    }
  },

  makeMarker(checkin, markerOptions){
    let defaults = {
      icon: L.mapbox.marker.icon({ 'marker-symbol' : 'heliport', 'marker-color' : '#ff6900' }),
      title: 'ID: ' + checkin.id,
      alt: 'ID: ' + checkin.id,
      checkin: checkin
    }
    markerOptions = $.extend({}, defaults, markerOptions)
    return L.marker([checkin.lat, checkin.lng], markerOptions)
  }
}

