$(document).on('ready page:change', function() {
  if (window.location.pathname == "/"){
    $("main").css('padding-top', '0');

    var $landingSection = $(".landing-section img");
    $(document).scroll(function() {
      $landingSection.each(function(i, el) {
        if ($(this).isOnScreen()) {
          $(this).addClass('animated');
        }
      });
    });

    $(".landing-section .start-btn").click(function(e){
      var offset = $(".landing-section.splash").height() - 64;
      $("body").animate({ scrollTop: offset });
    });
  }else{
    $("main").css('padding-top', '64px');
  }
});