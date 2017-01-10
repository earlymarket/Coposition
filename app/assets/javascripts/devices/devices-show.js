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

      $('body').on('click', '.edit-lat', function (e) {
        $(this).toggleClass('hide', true);
        makeEditable($(this).prev('span'), handleEdited, 'lat');
      });

      $('body').on('click', '.edit-lng', function (e) {
        $(this).toggleClass('hide', true);
        makeEditable($(this).prev('span'), handleEdited, 'lng');
      });

      function makeEditable ($target, handler, type) {
        var original = $target.text();
        $target.attr('contenteditable', true);
        $target.focus();
        document.execCommand('selectAll', false, null);
        $target.on('blur', function () {
          handler(original, $target, type);
        });
        $target.on('keydown', function (e) {
          if(e.which === 27 || e.which === 13 ) {
            handler(original, $target, type);
          }
        });
        return $target;
      }

      function handleEdited (original, $target, type) {
        var newCoord = $target.text()
        var newCoordFloat = parseFloat(newCoord)
        if(newCoordFloat && Math.abs(newCoordFloat) < 180 && original !== newCoord) {
          var url = $target.parents('span').attr('href');
          var data = { checkin: {} }
          data.checkin[type] = newCoord;
          var request = $.ajax({
            dataType: 'json',
            url: url,
            type: 'PUT',
            data: data
          });
          request
          .done(function (response) {
            checkin = _.find(gon.checkins, _.matchesProperty('id',response.id));
            checkin[type] = parseFloat(newCoord);
            checkin.lastEdited = true;
            M.queueRefresh(gon.checkins);
          })
          .fail(function (error) {
            $target.text(original);
          })
        } else {
          $target.text(original);
        }
        $target.attr('contenteditable', false);
        $target.next().toggleClass('hide', false);
        U.deselect();
        $target.off();
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
