$(document).on('page:change', function() {
  var U = window.COPO.utility
  if (U.currentPage('checkins', 'index')) {
    $('.date-select').collapsible({
        onOpen: U.dateRangeOpen,
        onClose: U.dateRangeClose
    });

    $('.device-select').collapsible({
        onOpen: () => $(".collapse-devices").text("expand_less"),
        onClose: () => $(".collapse-devices").text("expand_more")
    });

    if (window.location.search.includes("device_ids")) {
      $('.device-select').collapsible('open', 0);
      $(".collapse-devices").text("expand_less");
    }
  }
})
