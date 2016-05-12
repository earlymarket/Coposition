window.COPO = window.COPO || {};
window.COPO.smooch = {
  initSmooch: function(user){
    Smooch.init({
      appToken: "48zalrms2pp1raaolssv7dry8",
      userId: user.id.toString(),
      email: user.email,
      givenName: user.username
    });
  }
}
