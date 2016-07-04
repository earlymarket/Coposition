$(document).on('page:change', function() {
  if (($(".c-approvals.a-apps").length === 1) || ($(".c-approvals.a-friends").length === 1)) {
    const U  = window.COPO.utility;
    const M  = window.COPO.maps;

    $('.tooltipped').tooltip({delay: 50});
    U.gonFix();
    const PAGE = ($(".c-approvals.a-apps").length === 1 ? 'apps' : 'friends')
    COPO.permissionsTrigger.initTrigger(PAGE)
    COPO.permissions.initSwitches(PAGE, gon.current_user_id, gon.permissions)

    if(gon.friends && gon.friends.some(friend => friend.lastCheckin)) {
      $('.friends-index').removeClass('hide');
      M.initMap();
      M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
      M.addFriendMarkers(gon.friends)
    } else if(gon.friends){
      $('.friends-index').removeClass('hide');
      M.initMap();
      $('#map-overlay').removeClass('hide');
    }

    $(document).on('page:before-unload', function(){
      COPO.permissions.switchesOff();
    })
  }
})
