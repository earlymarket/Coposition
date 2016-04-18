$(document).on('page:change', function() {
  if ($(".c-approvals").length === 1) {
    $('.tooltipped').tooltip({delay: 50});
    COPO.permissions.setMasters('approved');
    COPO.permissions.masterChange('approved');
    COPO.permissions.switchChange('approved');
    COPO.permissions.checkDisabled();
    COPO.permissions.checkBypass();
  }
})
