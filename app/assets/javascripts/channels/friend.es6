App.friend = App.cable.subscriptions.create("FriendChannel", {
  received(data) {
    switch (data.action) {
      case "checkin":
        window.COPO.pushCreateCheckin.push(data);
        break;
      case "destroy":
        window.COPO.pushDestroyCheckin.push(data);
        break;
      case "request_checkin":
        Materialize.toast(data.message, 3000)
        break;
    }
  }
});
