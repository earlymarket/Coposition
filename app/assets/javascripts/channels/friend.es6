App.friend = App.cable.subscriptions.create("FriendChannel", {
  // connected: function() {
  // },

  // disconnected: function() {
  // },

  received: function(data) {
    switch (data.action) {
      case "checkin":
        if (!gon.checkins) { return };

        gon.checkins.unshift(data.msg);
        COPO.maps.refreshMarkers(gon.checkins);

        break;
    }
  }
});
