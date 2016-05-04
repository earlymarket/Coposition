window.COPO = window.COPO || {};
window.COPO.dateRange = {
  initDateRange(checkins) {
    const min = checkins.length ? moment(checkins[checkins.length-1].created_at) : moment().subtract(3, "months");
    $("#dateRange").ionRangeSlider({
      type: "double",
      force_edges: true,
      grid: true,
      drag_interval: true,
      min: min.format("X"),
      max: moment().endOf("day").format("X"),
      from: moment().subtract(1, "months").format("X"),
      to: moment().endOf("day").format("X"),
      prettify(num) {
        return moment(num, "X").format("LL");
      },
      onChange(num) {
        const CHECKINS = COPO.dateRange.filteredCheckins(checkins, moment(num.from, "X"), moment(num.to, "X"));
        COPO.maps.refreshMarkers(CHECKINS);
        COPO.charts.refreshCharts(CHECKINS);
      },
      onFinish(num) {
        //const CHECKINS = COPO.dateRange.filteredCheckins(checkins, moment(num.from, "X"), moment(num.to, "X"));
        //COPO.maps.refreshMarkers(CHECKINS);
        //COPO.charts.refreshCharts(CHECKINS);
      },
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
  }
}
