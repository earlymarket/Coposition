$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('approvals', 'index') || window.COPO.utility.currentPage('approvals', 'new') ) {
  	window.COPO.utility.setActivePage('users')
  }
})
