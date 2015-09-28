$(document).on('page:change', function(){
  setup();
});

$(document).on('page:fetch', function() {
  utility.animations.exitPage();
});


function setup() {
  utility.animations.enterPage();
  addEventListeners();
};

function addEventListeners() {
  addClickListeners();
};



function addClickListeners() {
  $(".close").click(function(e){
    utility.animations.removeEl($(e.currentTarget).parent());
  });
};