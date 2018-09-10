window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function() {
    var Smooch = require('smooch');
    if ($('#web-messenger-container').length > 0) return
    var params = { appId: "5730bb0aac38494200fa8385" };
    var user = COPO.smooch.checkForUserInformation();

    if (user && user.id && user.email && user.username) {
      params.userId    = user.id.toString();
      params.email     = user.email;
      params.givenName = user.username;
    }
    Smooch.init(params);
  },

  checkForUserInformation: function() {
    if (typeof(gon) == "undefined") return null;
    if (gon.current_user && gon.current_user.userinfo) {
      return gon.current_user.userinfo;
    } else if (gon.userinfo) {
      return gon.userinfo;
    } else {
      return null;
    }
  }
}
