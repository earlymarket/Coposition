var utility = {
  enterPage: function(){
    console.log("enter");
    $("#container").removeClass("slideOutLeft").addClass("slideInRight")
  },
  exitPage: function(){
    console.log("exit");
    $("#container").removeClass("slideInRight").addClass("slideOutLeft")
  }
}