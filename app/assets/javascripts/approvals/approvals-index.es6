$(document).on('page:change', function() {
  var U  = window.COPO.utility;
  if (U.currentPage('approvals', 'index') && typeof gon != "undefined") {
    const M  = window.COPO.maps;
    U.gonFix();
    const PAGE = "friends" in gon ? 'friends' : 'apps';
    COPO.permissionsTrigger.initTrigger(PAGE);
    COPO.permissions.initSwitches(PAGE, gon.current_user_id, gon.permissions);

    if (gon.friends && gon.friends.some(friend => friend.lastCheckin)) {
      COPO.utility.setActivePage('friends')
      $('.friends-index').removeClass('hide');
      gon.friends.forEach((friend) => {
        if (!friend.lastCheckin) {
          $('i[data-friend="' + friend.userinfo.id + '"]').remove();
        }
      });
      $('.center-map').on('click', function() {
        const friend_id = this.dataset.friend;
        const friend = gon.friends.find(friend => friend.userinfo.id.toString() === friend_id);
        const checkin = friend.lastCheckin;
        U.scrollTo('#quicklinks', 200);
        setTimeout(() => M.centerMapOn(checkin.lat, checkin.lng), 200);
      });
      M.initMap();
      M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
      M.addFriendMarkers(gon.friends)
    } else if (gon.friends) {
      $('.friends-index').removeClass('hide');
      M.initMap();
      $('#map-overlay').removeClass('hide');
    } else {
      COPO.utility.setActivePage('apps')
    }

    $(document).one('turbolinks:before-render', function() {
      COPO.permissions.switchesOff();
    })
  }
})
