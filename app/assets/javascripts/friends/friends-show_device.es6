$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('friends', 'show_device')) {
  	function dateRangeOpen() {
  	  $(".collapse-mark").text("expand_less");
  	}
  	function dateRangeClose() {
  	  $(".collapse-mark").text("expand_more");
  	}
  }
})
