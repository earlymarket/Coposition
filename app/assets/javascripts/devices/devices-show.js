$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers();
    COPO.maps.initControls();
    COPO.maps.lc.start();

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
      coords.checkinLink = COPO.utility.createCheckinLink(e.latlng);
      template = $('#createCheckinTmpl').html();
      template = Mustache.render(template, coords);
      var popup = L.popup().setLatLng(e.latlng).setContent(template);
      popup.openOn(map);
    })

    map.on('popupopen', function(e){
      var coords = e.popup.getLatLng()
      if($('#current-location').length){
        $createCheckinLink = COPO.utility.createCheckinLink(coords);
        $('#current-location').replaceWith($createCheckinLink);
      }
    })
  }

  $(document).on('page:before-unload', function(){
    map.stopLocate();
  })

});
