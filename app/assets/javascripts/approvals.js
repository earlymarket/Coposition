$(document).on('page:change', function() {
  if (($(".c-approvals.a-apps").length === 1) || ($(".c-approvals.a-friends").length === 1)) {
    $('.tooltipped').tooltip({delay: 50});
    COPO.utility.gonFix();
    var page = ($(".c-approvals.a-apps").length === 1 ? 'apps' : 'friends')
    COPO.permissions.initSwitches(page, gon.current_user_id, gon.permissions)

    $(document).on('page:before-unload', function(){
      COPO.permissions.switchesOff();
    })
  }
})
