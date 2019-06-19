$(document).on('page:change', function() {
  const U = window.COPO.utility;
  if (U.currentPage('activities', 'index')) {
    U.initTypeahead("users", gon.users)
  }
})
