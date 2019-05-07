$(document).on('page:change', function() {
  const U = window.COPO.utility;
  if (U.currentPage('activities', 'index')) {
    $('.search .users_typeahead').typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    },
    {
      name: 'users',
      source: U.substringMatcher(gon.users)
    });
  }
})
