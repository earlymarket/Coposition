$(document).on('ready page:change', function() {
  // Target only the landing page (assuming at root of "/")
  if (window.location.pathname == "/") {
    $("main").css('padding-top', '0');

    // Click event for the main button on landing page
    $(".landing-section .start-btn").unbind('click').click(function(e) {
      var offset = $(".landing-section.splash").height() - 64;
      $("body").animate({
        scrollTop: offset
      });
    });

    $(document).scroll(function(e) {
      var $currOffset = $(window).scrollTop();
      var winHeight = window.innerHeight;

      if($currOffset >= winHeight && $(".contents-menu").css('position') != "fixed"){
        $(".contents-menu").css('position', 'fixed');

      }else if($currOffset < winHeight && $(".contents-menu").css('position') == "fixed"){
        $(".contents-menu").css('position', 'relative');
      }

      if($currOffset >= 200 && $(document).height() - winHeight - $currOffset > $("footer").height()){
        $("#next-btn").css('opacity', '1');
      }else{
        $("#next-btn").css('opacity', '0');
      }
    });
    $(".promotion .card").unbind('click').click(function(e) {
      $(".promotion .card").removeClass('active');
      $(this).addClass('active');
    });

  } else {
    // Normalize the other pages
    $("main").css('padding-top', '64px');
  }
});