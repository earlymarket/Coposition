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
    COPO.utility.ujsLink('delete',
      '<i class="material-icons center red-text">delete_forever</i>' ,
      window.location.pathname + '/checkins/' + checkin.id )
      .attr('data-confirm', 'Are you sure?')
      .prop('outerHTML')
  },

  fogCheckinLink: function(checkin, foggedClass){
    COPO.utility.ujsLink('put',
      '<i class="material-icons center">cloud</i>' ,
      window.location.pathname + '/checkins/' + checkin.id )
      .attr('id', 'tableFog' + checkin.id).attr('class', foggedClass)
      .prop('outerHTML')
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
  }
};
