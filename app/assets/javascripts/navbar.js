$(document).on('ready page:change', function() {
  // sidebar menu collapses to a button on mobile
  $(".button-collapse").sideNav();

  // Transparent navbar for landing page
  if(window.location.pathname == "/"){
    $(document).scroll(function(e) {
      if($(window).scrollTop() > 10){
        $("nav").removeClass('transparent-nav');
        $("svg path").attr({
          fill: '#FFFFFF',
          'fill-opacity': '1'
        });
      }else if($(window).scrollTop() <= 10){
        $("nav").addClass('transparent-nav');
        $("svg path").attr({
          fill: '#000000',
          'fill-opacity': '0.8'
        });
      }
    });
  }else{
    $(document).unbind('scroll');
    $("nav").css('transition', 'none').removeClass('transparent-nav');
    $("svg path").attr({
      fill: '#FFFFFF',
      'fill-opacity': '1'
    });
  }
});