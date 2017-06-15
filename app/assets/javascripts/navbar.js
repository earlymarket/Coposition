$(document).on('page:change', function() {
  $(document).unbind('scroll');

  if (window.COPO.utility.currentPage('welcome', 'index') || window.COPO.utility.currentPage('welcome', 'devs')) {
    $(document).scroll(function(e) {
      if($(window).scrollTop() > 10){
        $("nav").removeClass('transparent-nav');
      } else {
        $("nav").addClass('transparent-nav');
      }
    })
  }
});
