/* exported utility */
var utility = {
  urlParam: function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) return null;
    return results[1] || 0;
  }
};
