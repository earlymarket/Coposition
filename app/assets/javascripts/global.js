$(document).on('page:change', function(){
  setup();
});

$(document).on('page:fetch', function() {
  utility.animations.exitPage();
});


function setup() {
  animateThings();
  addEventListeners();
};

function addEventListeners() {
  addClickListeners();
};


function animateThings() {
  utility.animations.enterPage();
  setupTextillate();
};


function setupTextillate() {
  $('.tlt').textillate(
    {
      in: {
        delayScale: 0.9
      }
    }
  );
};

function addClickListeners() {
  $(".close").click(function(e){
    utility.animations.removeEl($(e.currentTarget).parent());
  });
};