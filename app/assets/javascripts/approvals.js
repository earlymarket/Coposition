$(document).on('page:change', function() {
  if (($(".c-approvals").length === 1) && ($(".a-new").length === 0) && ($(".a-index").length === 0)){
    $('.tooltipped').tooltip({delay: 50});
    COPO.permissions.initSwitches('approved', gon.current_user_id, gon.permissions)
  }
})
