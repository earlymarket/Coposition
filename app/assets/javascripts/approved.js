$(document).on('page:change', function() {
  if ($(".c-approvals").length === 1) {
    $('.tooltipped').tooltip({delay: 50});
  }
})
