App.friend = App.cable.subscriptions.create("FriendChannel", {
  connected: function() {
    console.log("CONNECTED");
  },

  disconnected: function() {
    console.log("DISCONNECTED");
  },

  received: function(data) {
    console.log(data);
    switch (data.action) {
      case "checkin":
        if (!gon.checkins) { return };

        gon.checkins.unshift(data.msg);
        COPO.maps.refreshMarkers(gon.checkins);

        break;
    }
  }
});
