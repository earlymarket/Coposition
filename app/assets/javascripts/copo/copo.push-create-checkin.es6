window.COPO = window.COPO || {};
window.COPO.pushCreateCheckin = {
	push(data) {
		if (window.COPO.utility.currentPage('friends', 'show-device')) {
		  window.COPO.pushCreateCheckin.deviceShow(data);
		} else if (window.COPO.utility.currentPage('friends', 'show')) {
		  window.COPO.pushCreateCheckin.friendShow(data);
		} else if (window.COPO.utility.currentPage('approvals', 'friends')) {
		  window.COPO.pushCreateCheckin.friendsIndex(data);
		}
	},

	deviceShow(data) {
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
}