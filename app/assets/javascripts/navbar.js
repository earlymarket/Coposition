$(document).on('page:change', function() {
  // sidebar menu collapses to a button on mobile
  $(".button-collapse").sideNav();
  $(document).unbind('scroll');

  if ($(".c-welcome.a-index").length === 1) {
    $(document).scroll(function(e) {
      if($(window).scrollTop() > 10){
        $("nav").removeClass('transparent-nav');
      } else {
        $("nav").addClass('transparent-nav');
      }
    })
  }
});
