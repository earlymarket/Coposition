window.COPO = window.COPO || {};
window.COPO.dateRange = {

  initDateRange(checkins){
    const min = checkins.length ? moment(checkins[checkins.length-1].created_at) : moment().subtract(3, "months");
    $("#dateRange").ionRangeSlider({
      type: "double",
      force_edges: true,
      grid: true,
      drag_interval: true,
      min: min.format("X"),
      max: moment().format("X"),
      from: moment().subtract(1, "months").format("X"),
      to: moment().subtract(0, "months").format("X"),
      prettify(num) {
        return moment(num, "X").format("LL");
      },
      onChange(num) {
        const FROM = moment(num.from, "X");
        const TO = moment(num.to, "X");
        const CHECKINS = COPO.dateRange.filteredCheckins(checkins, FROM, TO);
        COPO.maps.refreshMarkers(CHECKINS);
        COPO.charts.refreshCharts(CHECKINS);
      },
      onFinish(num) {
        //const FROM = moment(num.from, "X");
        //const TO = moment(num.to, "X");
        //const CHECKINS = COPO.dateRange.filteredCheckins(checkins, FROM, TO);
        //COPO.maps.refreshMarkers(CHECKINS);
        //COPO.charts.refreshCharts(CHECKINS);
      },
    });
  },

  filteredCheckins(checkins, FROM, TO){
    function isAfter(checkin){
      if (moment(checkin.created_at).valueOf() >= moment(FROM).valueOf()) {
        return checkin;
      }
    }
    function isBefore(checkin){
      if (moment(checkin.created_at).valueOf() <= moment(TO).valueOf()) {
        return checkin;
      }
    }
    const filteredCheckins = checkins.filter(isAfter).filter(isBefore);
    return filteredCheckins;
  }
}
