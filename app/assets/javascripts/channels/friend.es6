App.friend = App.cable.subscriptions.create("FriendChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

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
