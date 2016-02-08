$(document).on('ready page:change', function() {
  if (window.location.pathname == "/") {
    $("main").css('padding-top', '0');
    $(".landing-section .start-btn").unbind('click').click(function(e) {
      var offset = $(".landing-section.splash").height() - 64;
      $("body").animate({
        scrollTop: offset
      });
    });

    $("#next-btn a").unbind('click').click(function(e) {
      scrollToNext();
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

    $("#next-btn").unbind('click').click(function(e) {
      var $buffer = $(".contents-menu a");

      $buffer.each(function(index, el) {
        if($(this).hasClass('active')){
          $(".contents-menu a:eq(" + (index+1) + ")").trigger('click');
        }
      });
    });

    $(".promotion .card").unbind('click').click(function(e) {
      $(".promotion .card").removeClass('active');
      $(this).addClass('active');
    });

  } else {
    $("main").css('padding-top', '64px');
  }
});
function scrollToNext() {

}