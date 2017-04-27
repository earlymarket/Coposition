$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('activities', 'index')) {
    var substringMatcher = function(strs) {
      return function findMatches(q, cb) {
        let matches = [];
        let substrRegex = new RegExp(q, 'i');
        $.each(strs, function(i, str) {
          if (substrRegex.test(str)) {
            matches.push(str);
          }
        });
        cb(matches);
      };
    };

    $('.search .users_typeahead').typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    },
    {
      name: 'users',
      source: substringMatcher(gon.users)
    });
  }
})
