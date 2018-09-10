$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('registrations', 'edit')) {
    window.COPO.utility.setActivePage('account');
    $('#edit_user').on('submit', function() {
      $('.inactive').attr('disabled', 'disabled');
    });
  }
})
