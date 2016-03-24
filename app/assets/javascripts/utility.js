/* exported utility */

window.COPO = window.COPO || {};

COPO.utility = {
  urlParam: function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) return null;
    return results[1] || 0;
  },

  ujsLink: function(verb, text, path){
    var output =  $('<a data-remote="true" rel="nofollow" data-method="' + verb +'" href="' + path +'">' + text +'</a>')
    return output
  },

  friendsName: function(friend){
    return friend.username ? friend.username : friend.email.split('@')[0]
  },

  fadeUp: function(target){
    $(target).velocity({
      opacity: 0,
      marginTop: '-40px'
    }, {
      duration: 375,
      easing: 'easeOutExpo',
      queue: false,
      complete: function(){
        $(target).remove();
      }
    });
  },

  avatar: function(public_id, options){
      options = options || {}
        if(public_id) {
          return $.cloudinary.image(public_id, options).prop('outerHTML')
        } else {
          return $.cloudinary.image("placeholder_wzhvlw.png", options).prop('outerHTML')
        }
      }
};
