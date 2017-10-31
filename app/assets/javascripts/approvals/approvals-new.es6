$(document).on('page:change', function() {
  let U = window.COPO.utility;
  if (U.currentPage('approvals', 'new') && typeof gon != "undefined") {
    window.location.search.includes("User") ? COPO.utility.setActivePage('friends') : COPO.utility.setActivePage('apps')
    $(".search .devs_typeahead").typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    },
    {
      name: 'devs',
      source: U.substringMatcher(gon.devs)
    });
  }
})
