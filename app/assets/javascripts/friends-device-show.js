$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1) {
    COPO.maps.initMap();
    COPO.maps.initMarkers(COPO.dateRange.filteredCheckins(gon.checkins, moment().subtract(1, "months"), moment().endOf("day")));
    COPO.maps.initControls();
    COPO.dateRange.initDateRange(gon.checkins);
  }
});

