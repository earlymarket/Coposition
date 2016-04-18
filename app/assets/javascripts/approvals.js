$(document).on('page:change', function() {
  if ($(".c-approvals").length === 1) {
    $('.tooltipped').tooltip({delay: 50});
    COPO.permissions.setMasters('approved', gon.permissions);
    COPO.permissions.masterChange('approved', gon.permissions);
    COPO.permissions.switchChange('approved', gon.permissions);
    COPO.permissions.checkDisabled();
    COPO.permissions.checkBypass();
  }
})
