/*global utility toastr:true*/

$(document).on('page:change', function(){
  setup()
});

$(document).on('page:fetch', function() {
  utility.animations.exitPage()
});


function setup() {
  addEventListeners()
}

function addEventListeners() {
  addClickListeners()
}

function addClickListeners() {
  $(".close").click(function(e){
    utility.animations.removeEl($(e.currentTarget).parent())
  });

  $(".landing-section .start-btn").click(function(e){
    var offset = $(".landing-section.first").height() + $("nav").height();
    $("body").animate({ scrollTop: offset });
  });
}
