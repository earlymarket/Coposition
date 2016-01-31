$(document).on('ready page:change', function() {
  // Materialize initialization
  $(".dropdown-button").dropdown({
    hover: true,
    belowOrigin: true
  });
  $(".button-collapse").sideNav();
  $('.collapsible').collapsible();
  $('.parallax').parallax();
  Waves.displayEffect();
  $('select').material_select();

  // Event listeners
  setup();
});


function setup() {
  animateThings();
  addEventListeners();
}

function addEventListeners() {
  addClickListeners();
}


function animateThings() {
  utility.animations.enterPage();
}


function addClickListeners() {
  $(".close").click(function(e){
    utility.animations.removeEl($(e.currentTarget).parent());
  });

  $(".landing-section .start-btn").click(function(e){
    var offset = $(".landing-section.splash").height();
    $("body").animate({ scrollTop: offset });
  });
}