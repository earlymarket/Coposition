window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function() {
    if(Smooch.appToken && $('#sk-holder').length === 0) {
      Smooch.render()
    } else {
      var params = {appToken: "48zalrms2pp1raaolssv7dry8"};
      var user = COPO.smooch.checkForUserInformation()

      if (user) {
        params.userId    = user.id.toString();
        params.email     = user.email;
        params.givenName = user.username;
      }

      Smooch.init(params);
    }
  },

  checkForUserInformation: function() {
    if (typeof(gon) == "undefined") return
    if (gon.current_user && gon.current_user.userinfo) {
      return gon.current_user.userinfo
    } else if (gon.userinfo) {
      return gon.userinfo
    }
  }
}
