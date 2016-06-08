window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function(user){
    if(Smooch.appToken && $('#sk-holder').length === 0){
      Smooch.render()
    } else {
      Smooch.init({
        appToken: "48zalrms2pp1raaolssv7dry8",
        userId: user.id.toString(),
        email: user.email,
        givenName: user.username
      });
    }
  }
}
