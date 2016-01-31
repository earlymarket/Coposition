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
  addEventListeners();
}

function addEventListeners() {
  addClickListeners();
}


function addClickListeners() {
  $(".landing-section .start-btn").click(function(e){
    var offset = $(".landing-section.splash").height();
    $("body").animate({ scrollTop: offset });
  });
}