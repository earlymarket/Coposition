App.friend = App.cable.subscriptions.create("FriendChannel", {
  connected: function() {
    console.log("CONNECTED");
  },

  disconnected: function() {
  console.log("DISCONNECTED");
  },

  received(data) {
    switch (data.action) {
      case "checkin":
        window.COPO.pushCreateCheckin.push(data);
        break;
      case "destroy":
        window.COPO.pushDestroyCheckin.push(data);
        break;
    }
  }
});
