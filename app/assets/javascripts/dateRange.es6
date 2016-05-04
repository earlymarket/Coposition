window.COPO = window.COPO || {};
window.COPO.dateRange = {

  initDateRange: function(checkins){
    $("#dateRange").ionRangeSlider({
      type: "double",
      force_edges: true,
      grid: true,
      drag_interval: true,
      min: +moment().subtract(3, "years").format("X"),
      max: +moment().format("X"),
      from: +moment().subtract(1, "months").format("X"),
      to: +moment().subtract(0, "months").format("X"),
      prettify: function (num) {
        return moment(num, "X").format("LL");
      },
      onChange: function (num) {
        let FROM = moment(num.from, "X");
        let TO = moment(num.to, "X");
        let CHECKINS = COPO.dateRange.filteredCheckins(checkins, FROM, TO);
        COPO.maps.refreshMarkers(CHECKINS);
        COPO.charts.refreshCharts(CHECKINS);
      },
      onFinish: function (num) {
        //let FROM = moment(num.from, "X");
        //let TO = moment(num.to, "X");
        //let CHECKINS = COPO.dateRange.filteredCheckins(checkins, FROM, TO);
        //COPO.maps.refreshMarkers(CHECKINS);
        //COPO.charts.refreshCharts(CHECKINS);
      },
    });
  },

  filteredCheckins: function(checkins, FROM, TO){
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
    let filteredCheckins = checkins.filter(isAfter).filter(isBefore);
    return filteredCheckins;
  }
}
