/* exported utility */

window.COPO = window.COPO || {};

COPO.utility = {
  urlParam: function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) return null;
    return results[1] || 0;
  },

  foggedIcon: function(boolean){
    if(boolean){
      return '<i class="material-icons">cloud_done</i>'
    } else {
      return '<i class="material-icons">cloud_off</i>'
    }
  },

  ujsLink: function(verb, text, path){
    var output =  $('<a data-remote="true" data-method="' + verb +'" href="' + path +'">' + text +'</a>')
    if(verb === 'delete') output.attr('rel', 'nofollow');
    return output
  },
};
