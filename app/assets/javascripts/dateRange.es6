window.COPO = window.COPO || {};
window.COPO.dateRange = {
  initDateRange(checkins, page) {
    const MIN = checkins.length ? moment(checkins[checkins.length-1].created_at) : moment().subtract(3, "months");
    let FROM = moment().subtract(1, "months").format("X");
    if (checkins.length && moment(checkins[0].created_at).format("X").valueOf() <= FROM.valueOf()) {
      FROM = moment(checkins[0].created_at).subtract(1, "week").format("X");
    }
    $("#dateRange").ionRangeSlider({
      type: "double",
      force_edges: true,
      grid: true,
      drag_interval: true,
      min: MIN.format("X"),
      max: moment().endOf("day").format("X"),
      from: FROM,
      to: moment().endOf("day").format("X"),
      prettify(num) {
        return moment(num, "X").format("LL");
      },
      onFinish(num) {
        const CHECKINS = COPO.dateRange.filteredCheckins(checkins, moment(num.from, "X"), moment(num.to, "X"));
        COPO.maps.refreshMarkers(CHECKINS);
        COPO.maps.fitBounds();
        COPO.charts.refreshCharts(CHECKINS, page);
      },
    });
    window.COPO.dateRange._loaded = true;
    $(document).one('page:before-unload', function () {
      window.COPO.dateRange._loaded = false;
    });
  },

  filteredCheckins(checkins, FROM, TO) {
    function isBetweenDates(checkin) {
      const checkinDate = moment(checkin.created_at).valueOf()
      if (checkinDate >= moment(FROM).valueOf() && checkinDate <= moment(TO).valueOf()) {
        return checkin;
      }
    }

    const filteredCheckins = checkins.filter(isBetweenDates);
    return filteredCheckins;
  },

  currentCheckins(checkins){
    if (!COPO.dateRange.loaded) {
      return checkins;
    }
    const slider = $("#dateRange").data("ionRangeSlider");
    return COPO.dateRange.filteredCheckins(checkins, moment(slider.old_from, "X"), moment(slider.old_to, "X"))
  }
}
