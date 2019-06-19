$(document).on('page:change', function() {
  var U = window.COPO.utility
  if (U.currentPage('friends', 'show_device')) {
    $('.date-select').collapsible({
      onOpen: U.dateRangeOpen,
      onClose: U.dateRangeClose
    });
  }
})
