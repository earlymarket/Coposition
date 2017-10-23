window.COPO = window.COPO || {};
window.COPO.pushCreateCheckin = {
  push(data) {
    if (window.COPO.utility.currentPage('friends', 'show_device')) {
      window.COPO.pushCreateCheckin.friendDeviceShow(data);
    } else if (window.COPO.utility.currentPage('friends', 'show')) {
      window.COPO.pushCreateCheckin.friendShow(data);
    } else if (window.COPO.utility.currentPage('approvals', 'friends')) {
      window.COPO.pushCreateCheckin.friendsIndex(data);
    } else if (window.COPO.utility.currentPage('devices', 'index')) {
      window.COPO.pushCreateCheckin.devicesIndex(data);
    } else if (window.COPO.utility.currentPage('devices', 'show')) {
      window.COPO.pushCreateCheckin.devicesShow(data);
    }
  },

  friendDeviceShow(data) {
    if (data.privilege === 'complete') {
      gon.checkins.unshift(data.checkin);
    } else {
      gon.checkins = [data.checkin];
    }

    COPO.maps.refreshMarkers(gon.checkins);
  },

  friendShow(data) {
    const index = gon.checkins.findIndex((checkin) => checkin.device_id === data.checkin.device_id);

    if (!gon.checkins.length) {
      gon.checkins.unshift(data.checkin);
      $('#map-overlay').addClass('hide');
      COPO.maps.refreshMarkers(gon.checkins);		
    } else {
      if (index === -1) {
        gon.checkins.unshift(data.checkin);
      } else {
        gon.checkins[index] = data.checkin;
      }
      COPO.maps.refreshMarkers(gon.checkins);	
    }	
  },

  friendsIndex(data) {
    const index = gon.friends.findIndex((friend) => friend.userinfo.id === data.checkin.user_id);
    const friend = { lastCheckin: data.checkin, userinfo: gon.friends[index].userinfo }

    if (!gon.friends.every(friend => friend.lastCheckin)) {
      $('#map-overlay').addClass('hide');
      gon.friends[index] = friend;
      COPO.maps.addFriendMarkers(gon.friends)
    } else {
      gon.friends[index] = friend;
      COPO.maps.refreshFriendMarkers(gon.friends);
    }
  },

  devicesIndex(data) {
    if (data.checkin.user_id != gon.current_user_id) return
    Materialize.toast('Remote check-in received', 3000)
  },

  devicesShow(data) {
    if (data.checkin.user_id != gon.current_user_id) return
    Materialize.toast('Remote check-in received', 3000)
    gon.checkins.unshift(data.checkin);
    if ($('#checkins_view').val()) {
      COPO.maps.refreshMarkers(gon.checkins);
    }
  }
}
