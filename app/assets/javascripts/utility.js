/* exported utility */
var utility = {
  urlParam: function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results) return null; 
    return results[1] || 0;
  },
  animations: {
    enterPage: function(){
      $("#container").removeClass("slideOutLeft").addClass("slideInRight");
    },
    exitPage: function(){
      $("#container").removeClass("slideInRight").addClass("slideOutLeft");
    },
    removeEl: function(el) {
      el.addClass("flipOutX").slideUp(1000);
    }
  }
}
