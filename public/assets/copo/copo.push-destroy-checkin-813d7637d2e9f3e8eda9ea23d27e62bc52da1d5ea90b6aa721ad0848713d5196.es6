window.COPO = window.COPO || {};
window.COPO.pushDestroyCheckin = {
  push(data) {
    if (window.COPO.utility.currentPage('friends', 'show_device')) {
      window.COPO.pushDestroyCheckin.deviceShow(data);
    } else if (window.COPO.utility.currentPage('friends', 'show')) {
      window.COPO.pushDestroyCheckin.friendShow(data);
    } else if (window.COPO.utility.currentPage('approvals', 'friends')) {
      window.COPO.pushDestroyCheckin.friendsIndex(data);
    }
  },

  deviceShow(data) {
    const index = gon.checkins.findIndex((checkin) => checkin.id === data.checkin.id);
    if (index === -1) { return; }

    gon.checkins.splice(index, 1);
    if (gon.checkins.length === 0 && data.privilege === 'last') {
      gon.checkins = [data.new];
    }

    COPO.maps.refreshMarkers(gon.checkins);
  },

  friendShow(data) {
    const index = gon.checkins.findIndex((checkin) => checkin.id === data.checkin.id);
    if (index === -1) return;

    gon.checkins.splice(index, 1);
    if (data.new) gon.checkins.unshift(data.new);
    if (!gon.checkins.length) {
      $('#map-overlay').removeClass('hide');
    }
    COPO.maps.refreshMarkers(gon.checkins);		
  },

  friendsIndex(data) {
    const index = gon.friends.findIndex((friend) => friend.lastCheckin.id === data.checkin.id);
    if (index === -1) return;

    const friend = { lastCheckin: data.new, userinfo: gon.friends[index].userinfo }
    gon.friends.splice(index, 1);
    gon.friends.unshift(friend);
    if (gon.friends.some(friend => friend.lastCheckin)) {
      COPO.maps.refreshFriendMarkers(gon.friends);
    } else {
      map.removeLayer(COPO.maps.friendMarkers);
      $('#map-overlay').removeClass('hide');
    }
  },
}
