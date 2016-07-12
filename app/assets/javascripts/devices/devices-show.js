$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1 || $(".c-devices.a-show").length === 1) {
    var page = $(".c-devices.a-show").length === 1 ? 'user' : 'friend'
    COPO.utility.gonFix();
    COPO.maps.initMap();
    COPO.maps.initMarkers(COPO.dateRange.currentCheckins(gon.checkins), gon.total);
    COPO.maps.initControls();

    $('li.tab').on('click', function(event) {
      var tab = event.target.textContent
      setTimeout (function() {
        if (tab ==='Table'){
          COPO.charts.refreshCharts(COPO.dateRange.currentCheckins(gon.checkins), page);
          COPO.charts.refreshCharts(gon.checkins, page);
        } else {
          map.invalidateSize();
        }
      });
    });

    $(window).resize(function(){
      COPO.charts.refreshCharts(COPO.dateRange.currentCheckins(gon.checkins), page);
      COPO.charts.refreshCharts(gon.checkins, page);
    });

    if (page === 'user') {
      map.on('contextmenu', function(e){
        var coords = {
          lat: e.latlng.lat.toFixed(6),
          lng: e.latlng.lng.toFixed(6),
          checkinLink: COPO.utility.createCheckinLink(e.latlng)
        };
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
  }
});

