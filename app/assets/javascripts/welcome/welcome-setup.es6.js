$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('welcome', 'setup')) {
    window.COPO.utility.setActivePage('started')
  }
})
