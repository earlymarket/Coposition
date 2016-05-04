$(document).on('page:change', function() {
  if ($(".c-devices.a-show").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers(COPO.dateRange.filteredCheckins(gon.checkins, moment().subtract(1, "months"), moment().endOf("day")));
    COPO.maps.initControls();
    //COPO.datePicker.initDatePicker();
    COPO.dateRange.initDateRange(gon.checkins);
    // COPO.maps.lc.start();

    $('li.tab').on('click', function(event) {
      var tab = event.target.textContent
      setTimeout(function() {
        if (tab ==='Chart'){
          var slider = $("#dateRange").data("ionRangeSlider");
          var checkins = COPO.dateRange.filteredCheckins(gon.checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
          COPO.charts.refreshCharts(checkins);
        } else {
          map.invalidateSize();
        }
      });
    });

    $(window).resize(function(){
      var slider = $("#dateRange").data("ionRangeSlider");
      var checkins = COPO.dateRange.filteredCheckins(gon.checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
      COPO.charts.refreshCharts(checkins);
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
