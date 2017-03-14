App.friend = App.cable.subscriptions.create("FriendChannel", {
  // connected: function() {
  // },

  // disconnected: function() {
  // },

  received: function(data) {
    switch (data.action) {
      case "checkin":
        if ($(".c-friends.a-show_device").length === 0) { return };

        if(data.privilege === 'complete'){
          gon.checkins.unshift(data.msg);
        } else {
          gon.checkins = [data.msg];
        }

        COPO.maps.refreshMarkers(gon.checkins);

        break;
    }
  }
});