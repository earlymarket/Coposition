App.friend = App.cable.subscriptions.create("FriendChannel", {
  // connected: function() {
  // },

  // disconnected: function() {
  // },

  received(data) {
    switch (data.action) {
      case "checkin":
        window.COPO.pushCreateCheckin.push(data);
        break;
      case "destroy":
        window.COPO.pushDestroyCheckin.push(data);
        break;
      case "request_checkin":
        M.toast({html: data.message, displayLength: 3000})
        break;
    }
  }
});
