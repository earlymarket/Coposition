var Smooch = require('smooch');
window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function() {
    if ($('#sk-holder').length > 0 || typeof(Smooch) == "undefined") return
    if (!Smooch.appId) {
      var params = { appId: "5730bb0aac38494200fa8385" };
      var user = COPO.smooch.checkForUserInformation();

      if (user && user.id && user.email && user.username) {
        params.userId    = user.id.toString();
        params.email     = user.email;
        params.givenName = user.username;
      }
      Smooch.init(params);
    }
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

$(document).on('page:before-unload', function () {
  Smooch._container && $(Smooch._container).detach();
});

$(document).on('page:update', function () {
  Smooch._container && $('body').append(Smooch._container);
});
