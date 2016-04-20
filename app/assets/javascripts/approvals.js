$(document).on('page:change', function() {
  if ($(".c-approvals").length === 1) {
    $('.tooltipped').tooltip({delay: 50});
    COPO.permissions.initSwitches('approved', gon.current_user_id, gon.permissions)
  }
})
