window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function() {
    var Smooch = require('smooch');
    if ($('#web-messenger-container').length > 0 || typeof(Smooch) == "undefined") return

    var params = { appId: "5730bb0aac38494200fa8385" };
    var user = COPO.smooch.checkForUserInformation();

    if (user && user.id && user.email && user.username) {
      params.jwt       = COPO.smooch.signJwt(user.id.toString());
      params.userId    = user.id.toString();
      params.email     = user.email;
      params.givenName = user.username;
    }
    Smooch.init(params);
  },

  signJwt: function(userId) {
    var jwt = require('jsonwebtoken');
    return jwt.sign(
      {
        scope: 'appUser',
        userId: userId
      },
      "LMSubWZZMClKh1zjM9L_Oij5",
      {
        header: {
          alg: 'HS256',
          typ: 'JWT',
          kid: "app_58946045f8359427001c7adb"
        }
      }
    );
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
