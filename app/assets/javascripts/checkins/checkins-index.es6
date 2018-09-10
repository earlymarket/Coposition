$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('checkins', 'index')) {
    function dateRangeOpen() {
      $(".collapse-mark").text("expand_less");
    }
    function dateRangeClose() {
      $(".collapse-mark").text("expand_more");
    }

    function devicesOpen() {
      $(".collapse-devices").text("expand_less");
    }
    function devicesClose() {
      $(".collapse-devices").text("expand_more");
    }
    if (window.location.search.includes("device_ids")) {
      $('.device-select').collapsible('open', 0);
    }
  }
})
