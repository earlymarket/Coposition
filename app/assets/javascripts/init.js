$(document).on('ready page:change', function() {
  // Materialize initialization
  // materialize dropdown menu init
  $(".dropdown-button").dropdown({
    hover: true,
    belowOrigin: true
  });

  // sidebar menu collapses to a button on mobile
  $(".button-collapse").sideNav();

  // materialize accordion init
  $('.collapsible').collapsible();

  // materialize parallax init
  $('.parallax').parallax();

  // materialize wave effect init
  Waves.displayEffect();

  // materialize selectbox init
  $('select').material_select();

  // materialize scrollspy init
  $('.scrollspy').scrollSpy();

  // materialize scrollfire
  var options = [
    {selector: '#security', offset: 100, callback: 'Materialize.fadeInImage("#security .image-container")'},
    {selector: '#api', offset: 100, callback: 'Materialize.fadeInImage("#api .image-container")'}
  ];
  Materialize.scrollFire(options);

  // allow materialize toast to be dismissed on click instead of just the default swipe
  $(document).on('click', '#toast-container .toast', function() {
    $(this).velocity({
      opacity: 0,
      marginTop: '-40px'
    }, { duration: 375,
      easing: 'easeOutExpo',
      queue: false,
      complete: function(){
      $(this).remove();
    }});
  });

  $(document).scroll(function(e) {
    if($(window).scrollTop() > 10){
      $("nav").removeClass('transparent-nav');
      $(".login-btn").removeClass('transparent-btn').addClass('visible-btn');
    }else if($(window).scrollTop() <= 10){
      $("nav").addClass('transparent-nav');
      $(".login-btn").addClass('transparent-btn').removeClass('visible-btn');
    }
  });

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
