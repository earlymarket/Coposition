$(document).on('page:change', function() {
  let U = window.COPO.utility;
  if (U.currentPage('approvals', 'new') && typeof gon != "undefined") {
    (window.location.search.includes("User") ? U.setActivePage('friends') : U.setActivePage('apps'));
    U.initTypeahead("devs", gon.devs)
  }
})
