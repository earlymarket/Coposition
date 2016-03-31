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

  deleteCheckinLink: function(checkin){
    return COPO.utility.ujsLink('delete',
      '<i class="material-icons right red-text">delete_forever</i>' ,
      window.location.pathname + '/checkins/' + checkin.id )
      .attr('data-confirm', 'Are you sure?').prop('outerHTML')
  },

  fogCheckinLink: function(checkin, foggedClass, fogId){
    return COPO.utility.ujsLink('put',
      '<i class="material-icons">cloud</i>' ,
      window.location.pathname + '/checkins/' + checkin.id )
      .attr('id', fogId + checkin.id).attr('class', foggedClass).prop('outerHTML')
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

  avatar: function(avatar, customOptions){

    var defaultOptions = {
      width: 60,
      height: 60,
      crop: 'fill',
      radius: 'max',
      gravity: 'face:center'
    }

    var options = $.extend(defaultOptions, customOptions)

    if(avatar && avatar.hasOwnProperty('public_id')) {
      return $.cloudinary.image(avatar.public_id, options).prop('outerHTML')
    } else {
      return $.cloudinary.image("placeholder_wzhvlw.png", options).prop('outerHTML')
    }
  }
};
