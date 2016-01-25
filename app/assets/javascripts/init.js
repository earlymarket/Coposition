$(document).on('ready page:change', function() {
  $(".dropdown-button").dropdown({
    hover: true,
    belowOrigin: true
  });
  $(".button-collapse").sideNav();
  $('.collapsible').collapsible();
  $('.parallax').parallax();
  Waves.displayEffect();
  $('select').material_select();
});
