App.friend = App.cable.subscriptions.create("FriendChannel", {
  // connected: function() {
  // },

  // disconnected: function() {
  // },

  received: (data) => {
    switch (data.action) {
      case "checkin":
        const create = window.COPO.pushCreateCheckin;
        if ($(".c-friends.a-show_device").length === 1) { 
          create.deviceShow(data);
        } else if ($(".c-friends.a-show").length === 1) {
          create.friendShow(data);
        } else if ($(".c-approvals.a-friends").length === 1) {
          create.friendsIndex(data);
        }
        break;
      case "destroy":
        const destroy = window.COPO.pushDestroyCheckin;
        if ($(".c-friends.a-show_device").length === 1) { 
          destroy.deviceShow(data);
        } else if ($(".c-friends.a-show").length === 1) {
          destroy.friendShow(data);
        } else if ($(".c-approvals.a-friends").length === 1) {
          destroy.friendsIndex(data);
        }
        break;
    }
  }
});
