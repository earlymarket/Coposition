$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers(COPO.dateRange.filteredCheckins(gon.checkins, moment().subtract(1, "months"), moment().endOf("day")));
    COPO.maps.initControls();
    COPO.dateRange.initDateRange(gon.checkins, 'friend');

    $('li.tab').on('click', function(event) {
      var tab = event.target.textContent
      setTimeout(function() {
        if (tab ==='Chart'){
          var slider = $("#dateRange").data("ionRangeSlider");
          var checkins = COPO.dateRange.filteredCheckins(gon.checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
          COPO.charts.refreshCharts(checkins, 'friend');
        } else {
          map.invalidateSize();
        }
      });
    });

    $(window).resize(function(){
      var slider = $("#dateRange").data("ionRangeSlider");
      var checkins = COPO.dateRange.filteredCheckins(gon.checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
      COPO.charts.refreshCharts(checkins, 'friend');
     });
  }
});

