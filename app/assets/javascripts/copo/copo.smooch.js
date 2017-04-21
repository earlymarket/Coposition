window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function(user) {
    if(Smooch.appToken && $('#sk-holder').length === 0) {
      Smooch.render()
    } else {
      var params = {appToken: "48zalrms2pp1raaolssv7dry8"};

      if (user) {
        params.userId    = user.id.toString();
        params.email     = user.email;
        params.givenName = user.username;
      }

      Smooch.init(params);
    }
  }
}
