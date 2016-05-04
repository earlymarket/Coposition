$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1 || $(".c-devices.a-show").length === 1) {
    const page = $(".c-devices.a-show").length === 1 ? 'user' : 'friend'
    COPO.maps.initMap();
    COPO.maps.initMarkers(COPO.dateRange.filteredCheckins(gon.checkins, moment().subtract(1, "months"), moment().endOf("day")));
    COPO.maps.initControls();
    COPO.dateRange.initDateRange(gon.checkins, page);

    $('li.tab').on('click', function(event) {
      var tab = event.target.textContent
      setTimeout(function() {
        if (tab ==='Chart'){
          var slider = $("#dateRange").data("ionRangeSlider");
          var checkins = COPO.dateRange.filteredCheckins(gon.checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
          COPO.charts.refreshCharts(checkins, page);
        } else {
          map.invalidateSize();
        }
      });
    });

    $(window).resize(function(){
      var slider = $("#dateRange").data("ionRangeSlider");
      var checkins = COPO.dateRange.filteredCheckins(gon.checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
      COPO.charts.refreshCharts(checkins, page);
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

