window.COPO = window.COPO || {};
window.COPO.maps = {
  queueCalled: false,
  windowFocused: true,

  initMap(customOptions) {
    if (document.getElementById('map')._leaflet) return;
    L.mapbox.accessToken = 'pk.eyJ1IjoiZ2FyeXNpdSIsImEiOiJjaWxjZjN3MTMwMDZhdnNtMnhsYmh4N3lpIn0.RAGGQ0OaM81HVe0OiAKE0w';

    var defaultOptions = {
      maxZoom: 18,
      minZoom: 1,
      worldCopyJump: true
    }
    COPO.maps.windowFocus()
    var options = $.extend(defaultOptions, customOptions);
    window.map = L.mapbox.map('map', 'mapbox.light', options );
    $(document).one('turbolinks:before-render', COPO.maps.removeMap);
  },

  windowFocus() {
    $(window).focus(() => {
        COPO.maps.windowFocused = true;
    }).blur(() => {
        COPO.maps.windowFocused = false;
    });
  },

  initMarkers(checkins, total, cities) {
    map.once('ready', function() {
      COPO.maps.initMarkersMapLoaded(checkins, total, cities)
    });
  },

  initMarkersMapLoaded(checkins, total, cities) {
    COPO.maps.generatePath(checkins);
    COPO.maps.renderAllMarkers(checkins);
    COPO.maps.bindMarkerListeners(checkins);
    COPO.maps.loadAllCheckins(checkins, total, cities);
    if (COPO.maps.allMarkers.getLayers().length) {
      map.fitBounds(COPO.maps.allMarkers.getBounds().pad(0.5));
    } else {
      map.once('locationfound', function(e) {
        map.panTo(e.latlng);
      })
    }
  },

  loadAllCheckins(checkins, total, cities) {
    if (cities === true) {
      if (checkins.length) $('.cached-icon').addClass('cities-active');
      toastMessage();
      (total > 20000) ? loadCheckins(1) : loadCheckins(2)
    } else if (total >= gon.max) {
      COPO.maps.refreshMarkers(gon.cities);
      $('.cached-icon').addClass('cities-active');
      toastMessage()
    } else {
      (total > 20000) ? loadCheckins(1) : loadCheckins(2)
    }

    function getCheckinData(page) {
      if (window.COPO.utility.currentPage('devices', 'show')) {
        if (window.location.search.length !== 0) {
          return $.getJSON(`${window.location.pathname}/checkins${window.location.search}&page=${page}&per_page=5000`)
        } else {
          return $.getJSON(`${window.location.pathname}/checkins?page=${page}&per_page=5000`)
        }
      } else if (window.COPO.utility.currentPage('friends', 'show_device')) {
        return $.getJSON(`${window.location.pathname}${window.location.search}&page=${page}&per_page=5000`)
      } else {
        console.log('Page not recognised. No incremental loading.');
      }
    };

    function loadCheckins(page) {
      let display = !($('.cached-icon').hasClass('cities-active'))
      if (total > gon.checkins.length) {
        if (display) updateProgress(gon.checkins.length, total);
        getCheckinData(page).then(function(data) {
          display = !($('.cached-icon').hasClass('cities-active'))
          if (window.gon.total === undefined) return;
          gon.checkins = gon.checkins.concat(data.checkins);
          if (display) COPO.maps.refreshMarkers(gon.checkins);
          page++;
          loadCheckins(page, display);
        });
      } else {
        if (!display) return;
        $('.myProgress').remove();
        toastMessage()
      };
    }

    function toastMessage() {
      COPO.maps.windowFocused ?  toastMessages() : $(window).one('focus', toastMessages)
    }

    function toastMessages() {
      let citiesDisplayed = ($('.cached-icon').hasClass('cities-active'))
      if (gon.first_load && citiesDisplayed) {
        Materialize.toast('Up to last 100 cities visited shown', 3000)
      } else if (citiesDisplayed) {
        Materialize.toast('Cities loaded', 3000)
      } else if (total >= gon.max) {
        Materialize.toast('There were too many check-ins to load, cities are shown', 3000);
      } else if (gon.total === gon.checkins.length) {
        Materialize.toast('All check-ins loaded', 3000)
      } else {
        Materialize.toast('Check-ins loaded', 3000)
      }
    }

    function updateProgress(checkins, total) {
      let percentageLoaded = (checkins/total * 100) + '%';
      $('.myDeterminate').css('width', percentageLoaded);
    }
  },

  removeMap() {
    map.remove();
  },

  fitBounds() {
    if (COPO.maps.allMarkers.getLayers().length) {
      map.fitBounds(COPO.maps.allMarkers.getBounds().pad(0.5))
      if (COPO.maps.allMarkers.getLayers().length === 1) {
        COPO.maps.allMarkers.getLayers()[0].fire('click');
      }
    }
  },

  queueRefresh(checkins) {
    COPO.maps.queueCalled = true;
    map.once('zoomstart', function(e) {
      map.removeEventListener('popupclose');
      COPO.maps.refreshMarkers(checkins);
    })
    map.once('popupclose', function(e) {
      COPO.maps.refreshMarkers(checkins);
    })
  },

  refreshMarkers(checkins) {
    map.removeEventListener('popupclose');
    map.removeEventListener('zoomstart');

    map.closePopup();
    if (COPO.maps.markers) {
      map.removeLayer(COPO.maps.markers);
    }
    if (COPO.maps.last) {
      map.removeLayer(COPO.maps.last);
    }
    COPO.maps.refreshPath(checkins);
    COPO.maps.renderAllMarkers(checkins);
    COPO.maps.bindMarkerListeners(checkins);
    COPO.maps.clickLastEditedMarker();
    COPO.maps.queueCalled = false;
  },

  renderAllMarkers(checkins) {
    let markers = checkins.slice(1).map(checkin => COPO.maps.makeMarker(checkin));
    // allMarkers is used for calculating bounds
    COPO.maps.allMarkers = L.markerClusterGroup().addLayers(markers);
    COPO.maps.addLastCheckinMarker(checkins);
    // markers and last are distinct because we want the last checkin
    // to always be displayed unclustered
    COPO.maps.markers = L.markerClusterGroup().addLayers(markers, { chunkedLoading: true });
    map.addLayer(COPO.maps.markers);
  },

  addLastCheckinMarker(checkins) {
    if (!checkins.length) return;
    COPO.maps.last = COPO.maps.makeMarker(checkins[0], {
      icon: L.mapbox.marker.icon({ 'marker-symbol' : 'marker', 'marker-color' : '#47b8e0' }),
      title: 'ID: ' + checkins[0].id + ' - Most recent',
      alt: 'lastCheckin',
      zIndexOffset: 1000
    });
    COPO.maps.allMarkers.addLayer(COPO.maps.last);
    map.addLayer(COPO.maps.last);
  },

  bindMarkerListeners(checkins) {
    COPO.maps.allMarkers.eachLayer(function(marker) {
      COPO.maps.markerClickListener(checkins, marker);
    })
  },

  clickLastEditedMarker() {
    COPO.maps.allMarkers.eachLayer(function(marker) {
      if (marker.options.checkin.lastEdited) {
        marker.fire('click');
        marker.options.checkin.lastEdited = false;
      }
    })
  },

  markerClickListener(checkins, marker) {
    marker.on('click', function(e) {
      let checkin = this.options.checkin;
      COPO.maps.dateToLocal(checkin);
      if (!marker._popup) {
        var template = checkin.address ? COPO.maps.buildCheckinPopup(checkin, marker) : COPO.maps.buildCityPopup(checkin, marker)
        marker.bindPopup(L.Util.template(template, checkin));
        marker.openPopup();
      }
      if (window.COPO.utility.currentPage('devices', 'show')) {
        $.get({
          url: "/users/" + gon.current_user_id + "/devices/" + checkin.device_id + "/checkins/" + checkin.id,
          dataType: "script"
        })
      }
      //map.panTo(this.getLatLng());
      COPO.maps.w3w.setCoordinates(e);
    });
  },

  buildCheckinPopup(checkin, marker) {
    let address = checkin.city;
    if (checkin.address) {
      address = COPO.utility.commaToNewline(checkin.address)
    }
    var checkinTemp = {
      id: checkin.id,
      lat: checkin.lat.toFixed(6),
      lng: checkin.lng.toFixed(6),
      created_at: moment.utc(checkin.created_at).format("ddd MMM D YYYY HH:mm:ss") + ' UTC+0000',
      address: address,
      marker: marker._leaflet_id
    };

    var foggedClass;
    checkin.fogged ? foggedClass = 'fogged enabled-icon' : foggedClass = ' disabled-icon';
    checkinTemp.foggedAddress = function() {
      if (checkin.fogged) {
        return `<div class="foggedAddress"><h3 class="lined"><span class="lined-pad">Fogged Address</span></h3>
                <li>${checkin.fogged_city}</li></div>`
      }
    }
    checkinTemp.devicebutton = function() {
      if (window.COPO.utility.currentPage('devices', 'index')) {
        return `<a href="./devices/${checkin.device_id}" title="Device map">${checkin.device}</a>`
      } else {
        return `<a href="${window.location.pathname}/show_device?device_id=${checkin.device_id}" title="Device map">${checkin.device}</a>`
      }
    }
    checkinTemp.idLink = COPO.utility.idLink(checkin)
    checkinTemp.revertButton = checkin.revert ? COPO.utility.revertLink(checkin) : ''
    checkinTemp.edited = checkin.edited ? '(edited)' : ''
    checkinTemp.inlineCoords = COPO.utility.renderInlineCoords(checkin);
    checkinTemp.foggle = COPO.utility.fogCheckinLink(checkin, foggedClass, 'fog');
    checkinTemp.deletebutton = COPO.utility.deleteCheckinLink(checkin);
    checkinTemp.inlineDate = COPO.utility.renderInlineDate(checkin, checkinTemp);
    var template = $('#markerPopupTmpl').html();
    return Mustache.render(template, checkinTemp);
  },

  buildCityPopup(checkin, marker) {
    var checkinTemp = {
      id: gon.counts[checkin.city],
      lat: checkin.lat.toFixed(6),
      lng: checkin.lng.toFixed(6),
      created_at: moment.utc(checkin.created_at).format("ddd MMM D YYYY HH:mm:ss") + ' UTC+0000',
      address: checkin.city,
      marker: marker._leaflet_id
    };
    checkinTemp.inlineDate = `<span id="localTime">${checkinTemp.created_at}</span>`
    var template = $('#cityPopupTmpl').html();
    return Mustache.render(template, checkinTemp);
  },

  dateToLocal(checkin) {
    if (checkin.localDate) {
      map.once('popupopen', function() { $('#localTime').html(checkin.localDate) });
    } else {
      let created_at = Date.parse(checkin.created_at)/1000;
      let coords = [checkin.lat, checkin.lng];
      $.get(`https://maps.googleapis.com/maps/api/timezone/json?location=${checkin.lat},${checkin.lng}&timestamp=${created_at}&key=AIzaSyCEjHZhLTdiy7jbRTDU3YADs8a1yXKTwqI`)
      .done((data) => {
        if (data.status === 'OK') {
          let date = moment((created_at + data.rawOffset + data.dstOffset)*1000).format("ddd, Do MMM YYYY, HH:mm:ss");
          let offsetStr = COPO.maps.formatOffset(parseInt(data.rawOffset) + data.dstOffset);
          let localDate = `${date} (UTC${offsetStr})`;
          checkin.localDate = localDate;
          $('#localTime').html(localDate);
        }
      });
    }
  },

  formatOffset(offset) {
    // offset is an int that's the time offset in seconds from UTC
    // normally this is composed of dstOffset + rawOffset
    // formatOffset converts it to hours:mins format

    // Nepal Standard Time is UTC+05:45. offset: 20700
    // Newfoundland Standard Time is UTC−03:30: -12600

    // converted and padded to give HH:MM
    let offsetStr = [Math.floor(offset / 3600), (offset % 3600) / 60].map(digits => {
      return COPO.utility.padStr('0', 2, Math.abs(digits));
    }).join(':');

    // prepend + or -
    return offset < 0 ? '-' + offsetStr : '+' + offsetStr;
  },

  initControls(controls) {
    // When giving custom controls, I recommend adding layers last
    // This is because it expands downwards
    controls = controls || ['geocoder', 'locate', 'w3w', 'fullscreen', 'path', 'layers'];
    controls.forEach((control) => {
      let fn = this[control + 'ControlInit']
      if (typeof(fn) === 'function') {
        fn();
      }
    })
  },

  fullscreenControlInit() {
    L.control.fullscreen().addTo(window.map);
  },

  citiesControlInit() {
    const citiesControl = L.Control.extend({
      options: {
        position: 'topleft'
      },
      onAdd: (map) => {
        var container = L.DomUtil.create('div', 'leaflet-bar leaflet-control leaflet-control-custom');
        container.innerHTML = `
        <a class="leaflet-control-cities leaflet-bar-cities" href="#" onclick="return false;" title="Show cities">
          <i class="material-icons cached-icon">location_city</i>
        </a>
        `;
        container.onclick = function() {
          COPO.maps.citiesControlClick();
        }
        return container;
      }
    });
    map.addControl(new citiesControl());
  },

  layersControlInit() {
    let map = window.map;
    L.control.layers({
      'Light': L.mapbox.tileLayer('mapbox.light'),
      'Dark': L.mapbox.tileLayer('mapbox.dark'),
      'Streets': L.mapbox.tileLayer('mapbox.streets'),
      'Hybrid': L.mapbox.tileLayer('mapbox.streets-satellite'),
      'Satellite': L.mapbox.tileLayer('mapbox.satellite'),
      'High Contrast': L.mapbox.tileLayer('mapbox.high-contrast')
    }, null, {position: 'topleft'}).addTo(map);
  },

  geocoderControlInit() {
    map.addControl(L.mapbox.geocoderControl('mapbox.places',
      { position: 'topright',
        keepOpen: true
      }
    ));
  },

  locateControlInit() {
    COPO.maps.lc = L.control.locate({
      follow: false,
      setView: 'always',
      markerClass: L.CircleMarker,
      strings: {
        title: 'Your current location',
        popup: 'Your current location within {distance} {unit}.<br><a href="#" id="current-location"></a>'
      }
    }).addTo(map);
  },

  w3wControlInit() {
    COPO.maps.w3w = new L.Control.w3w({apikey: '4AQOB5CT', position: 'topright'});
    COPO.maps.w3w.addTo(map);
  },

  pathControlInit() {
    const pathControl = L.Control.extend({
      options: {
        position: 'topleft'
      },
      onAdd: (map) => {
        var container = L.DomUtil.create('div', 'leaflet-bar leaflet-control leaflet-control-custom');
        container.innerHTML = `
        <a class="leaflet-control-path leaflet-bar-path" href="#" onclick="return false;" title="View path">
          <i class="material-icons path-icon">timeline</i>
        </a>
        `
        container.onclick = function() {
          COPO.maps.pathControlClick();
        }
        return container;
      },
    });
    map.addControl(new pathControl());
  },

  mousePositionControlInit() {
    const mousePositionControl = L.Control.extend({
      options: {
        position: 'bottomleft',
      },

      onAdd: function(map) {
        this.container = L.DomUtil.create('div', 'leaflet-control-mouseposition');
        L.DomEvent.disableClickPropagation(this.container);
        map.on('mousemove', this.onMouseMove, this);
        this.container.innerHTML = 'Coordinates unavailable';
        return this.container;
      },

      onRemove: function(map) {
        map.off('mousemove', this.onMouseMove)
      },

      onMouseMove: function(e) {
        let latlng = COPO.maps.getBoundedLatlng(e)
        let value = `${latlng.lng.toFixed(6)}, ${latlng.lat.toFixed(6)}`;
        this.container.innerHTML = value;
      }
    });
    COPO.maps.mousePositionControl = new mousePositionControl();
    map.addControl(COPO.maps.mousePositionControl);
  },

  mapPinIcon(public_id, color) {
    // The iconClass is a named Cloudinary transform
    // At the moment there are only three: 'map-pin' and
    // 'map-pin-blue' and 'map-pin-grey'
    var iconClass;
    color ? iconClass = `map-pin-${ color }` : iconClass = 'map-pin'
    return L.icon({
      iconUrl: $.cloudinary.url(public_id, {format: 'png', transformation: iconClass}),
      iconSize: [50,50],
      iconAnchor: [25,46]
    })
  },

  arrayToCluster: (markerArr, markerBuilderFn) => {
    if (!markerBuilderFn) {
      return console.error('Marker building function undefined')
    }
    let cluster = markerArr.map(marker => markerBuilderFn(marker))
      .filter(marker => marker);
    return L.markerClusterGroup().addLayers(cluster)
  },

  friendsCheckinsToCluster: (markerArr) => {
    let cluster = markerArr.map(marker => {
      return COPO.maps.makeMapPin(marker, marker.pinColor);
    }).filter(marker => marker);
    return L.markerClusterGroup().addLayers(cluster)
  },

  makeMapPin(user, color, markerOptions) {
    let checkin = user.lastCheckin;
    if (checkin) {
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

  addFriendMarkers(checkins) {
    COPO.maps.friendMarkers = COPO.maps.bindFriendMarkers(checkins);
    map.addLayer(COPO.maps.friendMarkers);
    const BOUNDS = L.latLngBounds(
        _.compact(checkins.map(friend => friend.lastCheckin))
        .map(friend => L.latLng(friend.lat, friend.lng)))
    map.fitBounds(BOUNDS, {padding: [40, 40]})
  },

  bindFriendMarkers(checkins) {
    let markers = COPO.maps.friendsCheckinsToCluster(checkins);
    markers.eachLayer((marker) => {
      marker.on('click', function (e) {
        COPO.maps.panAndW3w.call(this, e)
      });
      marker.on('mouseover', (e) => {
        if (!marker._popup) {
          COPO.maps.friendPopup(marker);
        }
        COPO.maps.w3w.setCoordinates(e);
        marker.openPopup();
      });
    });
    return markers;
  },

  refreshFriendMarkers(checkins) {
    if (COPO.maps.friendMarkers) {
      map.removeLayer(COPO.maps.friendMarkers);
    }
    COPO.maps.addFriendMarkers(checkins);
  },

  friendPopup(marker) {
    let user    = marker.options.user;
    let name    = COPO.utility.friendsName(user);
    let date    = moment(marker.options.lastCheckin.created_at).fromNow();
    let address = marker.options.lastCheckin.city;
    if (marker.options.lastCheckin.address) {
      address = COPO.utility.commaToNewline(marker.options.lastCheckin.address)
    }
    let content = `
    <h2>${ name } <a href="./friends/${user.slug}" title="Device info">
      <i class="material-icons tiny">perm_device_information</i>
      </a></h2>
    <div class="address">${ address }</div>
    Checked in: ${ date }`
    marker.bindPopup(content, { offset: [0, -38] } );
  },

  makeMarker(checkin, markerOptions) {
    let defaults = {
      icon: L.mapbox.marker.icon({ 'marker-symbol' : 'marker', 'marker-color' : '#ff6900' }),
      title: 'ID: ' + checkin.id,
      alt: 'ID: ' + checkin.id,
      checkin: checkin
    }
    markerOptions = $.extend({}, defaults, markerOptions)
    return L.marker([checkin.lat, checkin.lng], markerOptions)
  },

  userToLatlng(user) {
    let checkin = user.lastCheckin;
    if (checkin) {
      return L.latLng(checkin.lat, checkin.lng)
    }
  },

  panAndW3w(e) {
    map.panTo(this.getLatLng());
    COPO.maps.w3w.setCoordinates(e);
  },

  centerMapOn(lat, lng) {
    map.setView(L.latLng(lat, lng), 18);
  },

  generatePath(checkins) {
    if (!checkins.length) return;
    const latLngs = checkins.map((checkin) => [checkin.lat, checkin.lng]);
    COPO.maps.checkinPath = L.polyline(latLngs, {color: 'red'});
  },

  refreshPath(checkins) {
    const path = COPO.maps.checkinPath;
    COPO.maps.generatePath(checkins);
    if (path && path._map) {
      map.removeLayer(path);
      COPO.maps.checkinPath.addTo(map);
    }
  },

  pathControlClick() {
    if (COPO.maps.checkinPath && COPO.maps.checkinPath._map) {
      $('.path-icon').removeClass('path-active')
      map.removeLayer(COPO.maps.checkinPath);
    } else if (COPO.maps.checkinPath) {
      $('.path-icon').addClass('path-active')
      COPO.maps.checkinPath.addTo(map);
    }
  },

  createCheckinPopup() {
    map.on('popupopen', function(e) {
      if ($('#current-location').length) {
        $createCheckinLink = window.COPO.utility.createCheckinLink(e.popup.getLatLng());
        $('#current-location').replaceWith($createCheckinLink);
      }
    })
  },

  rightClickListener() {
    map.on('contextmenu', function(e) {
      let latlng = COPO.maps.getBoundedLatlng(e)
      var coords = {
        lat: latlng.lat.toFixed(6),
        lng: latlng.lng.toFixed(6),
        checkinLink: window.COPO.utility.createCheckinLink(e.latlng)
      };
      var template = $('#createCheckinTmpl').html();
      var content = Mustache.render(template, coords);
      var popup = L.popup().setLatLng(e.latlng).setContent(content);
      popup.openOn(map);
    })
  },

  getBoundedLatlng (e) {
    let lng = e.latlng.lng
    let lat = e.latlng.lat
    if (lng > 180) {
      lng = lng - 360
    } else if (lng < -180) {
      lng = (parseFloat(lng) + 360)
    }
    return { lng: lng, lat: lat }
  },

  checkinNowListeners(callback) {
    $('#checkinNow').on('click', function() {
      callback(false);
    })
    $('#checkinFoggedNow').on('click', function() {
      callback(true);
    })
  },

  citiesControlClick() {
    if ($('.cached-icon').hasClass('cities-active')) {
      if (gon.total === gon.checkins.length) {
        $('.cached-icon').removeClass('cities-active');
        COPO.maps.refreshMarkers(gon.checkins);
      } else if (gon.total > 50000) {
        Materialize.toast('Too many check-ins to load.', 3000)
      } else if (gon.total > 20000) {
        sweetAlert(
          {
            title: "Show cities?",
            text: "This may take a long time to load, view cities?",
            type: "info",   
            showCancelButton: true,   
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "Yes",
            cancelButtonText: "No"
          }, 
          function(isConfirm) {
            if (!isConfirm) {
              Materialize.toast('Loading check-ins.', 3000)
              $('.cached-icon').removeClass('cities-active');
              COPO.maps.refreshMarkers(gon.checkins);
            }
          }
        );
      } else {
        Materialize.toast('Loading check-ins.', 3000)
        $('.cached-icon').removeClass('cities-active');
        COPO.maps.refreshMarkers(gon.checkins);
      }
    } else {
      $('.cached-icon').addClass('cities-active');
      COPO.maps.refreshMarkers(gon.cities);
    }
  }
}
