/* exported utility */
var utility = {
  urlParam: function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) return null;
    return results[1] || 0;
  },
  animations: {
    removeEl: function(el) {
      el.addClass("flipOutX").slideUp(1000);
    }
  }
};
