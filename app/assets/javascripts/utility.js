/* exported utility */

window.Copo = window.Copo || {};

Copo.Utility = {
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
  }
};
