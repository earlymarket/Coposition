$(document).on('page:change', function() {
  if (($(".c-approvals.a-index").length === 1)) {
    const U  = window.COPO.utility;
    const M  = window.COPO.maps;

    U.gonFix();
    const PAGE = "friends" in gon ? 'friends' : 'apps';
    COPO.permissionsTrigger.initTrigger(PAGE)
    COPO.permissions.initSwitches(PAGE, gon.current_user_id, gon.permissions)

    if(gon.friends && gon.friends.some(friend => friend.lastCheckin)) {
      $('.friends-index').removeClass('hide');
      gon.friends.forEach(friend => {
        if (!friend.lastCheckin) {
          $('i[data-friend="'+ friend.userinfo.id+'"]').remove();
        }
      });
      $('.center-map').on('click', function() {
        const friend_id = this.dataset.friend;
        const friend = gon.friends.find(friend => friend.userinfo.id.toString() === friend_id);
        const checkin = friend.lastCheckin;
        U.scrollTo('#top', 200);
        setTimeout(() => M.centerMapOn(checkin.lat, checkin.lng), 200);
      });
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
