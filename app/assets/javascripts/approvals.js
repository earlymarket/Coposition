$(document).on('page:change', function() {
  if (($(".c-approvals.a-apps").length === 1) || ($(".c-approvals.a-friends").length === 1)) {
    $('.tooltipped').tooltip({delay: 50});
    COPO.utility.gonFix();
    COPO.permissions.initSwitches('approved', gon.current_user_id, gon.permissions)

    $(document).on('page:before-unload', function(){
      COPO.permissions.switchesOff();
    })
  }
})
