$(document).on('ready page:change', function() {
  if (window.COPO.utility.currentPage('welcome', 'index') || window.COPO.utility.currentPage('welcome', 'devs')) {
    $("#top-menu").css("display", "block");

    $(".cell-wrapper").not('.slick-initialized').slick({
      autoplay: true,
      arrows: false,
      dots: true,
      mobileFirst: true,
      responsive: [{
        breakpoint: 600,
        settings: "unslick"
      }]
    });

    $(window).resize(function () {
      $(".cell-wrapper").slick("resize");
    });

    $(window).on("orientationchange", function () {
      $(".cell-wrapper").slick("resize");
    });
  } else {
    var resize = function(){
      if(window.innerWidth<660){
        $("main").css('padding-top', '76px');
      } else {
        $("main").css('padding-top', '21px');
      }
    }
    resize();
    $(window).resize(function () {
      resize();
    })
  }
});
