$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('welcome', 'help')) {
    window.COPO.utility.setActivePage('help')
  }
})
