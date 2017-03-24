App.friend = App.cable.subscriptions.create("FriendChannel", {
  // connected: function() {
  // },

  // disconnected: function() {
  // },

  received: function(data) {
    switch (data.action) {
      console.log(data.action);
      console.log(data.msg);
      case "checkin":
        if ($(".c-friends.a-show_device").length === 0) { return };

        if (data.privilege === 'complete') {
          gon.checkins.unshift(data.msg);
        } else {
          gon.checkins = [data.msg];
        }

        COPO.maps.refreshMarkers(gon.checkins);

        break;

      case "destroy":
        if ($(".c-friends.a-show_device").length === 0) { return };

        const index = gon.checkins.findIndex((checkin) => checkin.id === data.msg.id);
        gon.checkins.splice(index, 1);

        COPO.maps.refreshMarkers(gon.checkins);

        break;
    }
  }
});
