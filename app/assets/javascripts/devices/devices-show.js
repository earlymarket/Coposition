$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1 || $(".c-devices.a-show").length === 1) {
    var page = $(".c-devices.a-show").length === 1 ? 'user' : 'friend'
    var fogged = false;
    var U = window.COPO.utility;
    var M = window.COPO.maps;
    U.gonFix();
    M.initMap();
    M.initMarkers(gon.checkins, gon.total);
    M.initControls();
    var currentCoords;

    map.on('locationfound', onLocationFound);

    if (page === 'user') {
      map.on('contextmenu', function(e){
        var coords = {
          lat: e.latlng.lat.toFixed(6),
          lng: e.latlng.lng.toFixed(6),
          checkinLink: U.createCheckinLink(e.latlng)
        };
        template = $('#createCheckinTmpl').html();
        var content = Mustache.render(template, coords);
        var popup = L.popup().setLatLng(e.latlng).setContent(content);
        popup.openOn(map);
      })

      map.on('popupopen', function(e){
        var coords = e.popup.getLatLng()
        if($('#current-location').length){
          $createCheckinLink = U.createCheckinLink(coords);
          $('#current-location').replaceWith($createCheckinLink);
        }
      })

      $('#checkinNow').on('click', function(){
        fogged = false;
        getLocation();
      })

      $('#checkinFoggedNow').on('click', function(){
        fogged = true;
        getLocation();
      })

      $('body').on('click', '.edit-coords', function (e) {
        M.mousePositionControlInit();
        $(this).toggleClass('hide', true);
        var $target = $(this).prev('span');
        var original = $target.text();
        $target.attr('contenteditable', true);
        $target.focus();
        document.execCommand('selectAll', false, null);
        $('#map').css('cursor','crosshair');
        map.on('click', function(e){
          handleMapClick($target, e);
        });
        $('.leaflet-popup').on('click', function (e) {
          if(e.target.className !== 'editable'){
            handleCoordsEdited(original, $target);
          }
        });
        $target.on('keydown', function (e) {
          if(e.which === 27 || e.which === 13 ) {
            handleCoordsEdited(original, $target);
          }
        });
        COPO.maps.allMarkers.eachLayer(function(marker) {
          marker.on('click', function(e) {
            if($target.attr('contenteditable')==="true"){
              removeEditable($target);
            }
          });
        });
      });

      function handleCoordsEdited(original, $target) {
        var newCoords = $target.text();
        var coords = newCoords.split(",");
        if(coords.length == 2 && original !== newCoords){
          if(Math.abs(coords[0]) < 180 && Math.abs(coords[1]) < 180){
            var url = $target.parents('span').attr('href');
            var data = { checkin: { lat: parseFloat(coords[0]), lng: parseFloat(coords[1])} }
            postCheckin(url, data, M.queueRefresh);
          } else {
            $target.text(original);
          }
        } else {
          $target.text(original);
        }
        removeEditable($target);
      }

      function handleMapClick($target, e) {
        var r = confirm("Are you sure? Click ok to reposition check-in to new coordinates (" + e.latlng.lat.toFixed(6) + ", " + e.latlng.lng.toFixed(6) + ").");
        if (r == true) {
          var url = $target.parents('span').attr('href');
          var data = { checkin: {lat: e.latlng.lat, lng: e.latlng.lng} }
          postCheckin(url, data, M.refreshMarkers);
        }
        removeEditable($target);
      }

      function postCheckin(url, data, success){
        $.ajax({
          dataType: 'json',
          url: url,
          type: 'PUT',
          data: data
        })
        .done(function (response) {
          checkin = _.find(gon.checkins, _.matchesProperty('id',response.id));
          checkin.lat = response.lat;
          checkin.lng = response.lng;
          checkin.edited = response.edited;
          checkin.lastEdited = true;
          success(gon.checkins);
        })
        .fail(function (error) {
          console.log('Error updating checkin');
        })
      }

      function removeEditable($target){
        map.removeControl(COPO.maps.mousePositionControl);
        map.off('click');
        $('#map').css('cursor','auto');
        $target.parents('.leaflet-popup').off('click');
        $target.off('keydown');
        $target.attr('contenteditable', false);
        $target.next().toggleClass('hide', false);
        U.deselect();
      }
    }

    function postLocation(position){
      $.ajax({
        url: '/users/'+gon.current_user_id+'/devices/'+gon.device+'/checkins/',
        type: 'POST',
        dataType: 'script',
        data: { checkin: { lat: position.coords.latitude, lng: position.coords.longitude, fogged: fogged } }
      });
    }

    function getLocation(fogged){
      if(currentCoords){
        var position = { coords: { latitude: currentCoords.lat, longitude: currentCoords.lng } }
        postLocation(position)
      } else {
        navigator.geolocation.getCurrentPosition(postLocation, U.geoLocationError, { timeout: 5000 });
      }
    }

    function onLocationFound(p){
      currentCoords = p.latlng;
    }
  }
});
