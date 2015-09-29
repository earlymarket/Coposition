var utility = {
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