$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers(gon.checkins);
    COPO.maps.initControls();
    COPO.dateRange.initDateRange(gon.checkins);
    // COPO.maps.lc.start();

    $('li.tab').on('click', function(event) {
      var tab = event.target.textContent
      setTimeout(function() {
        if (tab ==='Chart'){
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
      var content = Mustache.render(template, coords);
      var popup = L.popup().setLatLng(e.latlng).setContent(content);
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

});
