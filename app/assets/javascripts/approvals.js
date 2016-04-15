$(document).on('page:change', function() {
  if ($(".c-approvals").length === 1) {
    $('.tooltipped').tooltip({delay: 50});
    COPO.permissions.set_masters('approved');
    COPO.permissions.master_change('approved');
    COPO.permissions.switch_change('approved');
    COPO.permissions.check_disabled();
    COPO.permissions.check_bypass();
  }
})
