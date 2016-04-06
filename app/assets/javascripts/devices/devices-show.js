$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.lc.start();
    //COPO.maps.popUpOpenListener();
    //COPO.maps.rightClickListener();
    //google.charts.setOnLoadCallback(COPO.charts.refreshCharts(gon.checkins));

    $('li.tab').on('click', function() {
      var tab = event.target.innerText
      setTimeout(function(event) {
        if (tab ==='CHART'){
          COPO.charts.refreshCharts(gon.checkins);
        } else {
          map.invalidateSize();
        }
      });
    });

    $(window).resize(function(){
      COPO.charts.refreshCharts(gon.checkins);
     });

    map.on('contextmenu', function(e){
      var coords = {};
      coords.lat = e.latlng.lat.toFixed(6);
      coords.lng = e.latlng.lng.toFixed(6);
      coords.checkinLink = createCheckinLink(e.latlng);
      template = $('#createCheckinTmp').html();
      template = Mustache.render(template, coords);
      var popup = L.popup().setLatLng(e.latlng).setContent(template);
      popup.openOn(map);
    })

    map.on('popupopen', function(e){
      var coords = e.popup.getLatLng()
      if($('#current-location').length){
        $createCheckinLink = createCheckinLink(coords);
        $('#current-location').replaceWith($createCheckinLink);
      }
    })

    function createCheckinLink(coords){
      var checkin = {
        'checkin[lat]': coords.lat.toFixed(6),
        'checkin[lng]': coords.lng.toFixed(6)
      }
      var checkinPath = location.pathname + '/checkins?' + $.param(checkin);
      return COPO.utility.ujsLink('post', 'Create checkin here', checkinPath).prop('outerHTML');
    }
  }
});
