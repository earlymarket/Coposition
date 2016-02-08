$(document).on('ready page:change', function() {
  var $landingSection = $(".landing-section img");
  
  $(document).scroll(function() {
    $landingSection.each(function(i, el) {
      if ($(this).isOnScreen()) {
        $(this).addClass('animated');
      }
    });
  });
});