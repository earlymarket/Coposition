$(document).on('ready page:change', function() {
  // Materialize initialization
  // materialize dropdown menu init
  $(".dropdown-button").dropdown({
    hover: true,
    belowOrigin: true
  });

  // We're calling this later now in the dodgy hack
  // // materialize accordion init
  // $('.collapsible').collapsible();

  // materialize parallax init
  $('.parallax').parallax();

  // materialize wave effect init
  Waves.displayEffect();

  // materialize selectbox init
  $('select').material_select();

  // materialize scrollfire
  var options = [
    // Landing-page fade in image
    {selector: '#security',
     offset: 100,
     callback: 'Materialize.fadeInImage("#security .image-container")'},
    {selector: '#api',
     offset: 100,
     callback: 'Materialize.fadeInImage("#api .image-container")'}
  ];
  Materialize.scrollFire(options);

  // allow materialize toast to be dismissed on click instead of just the default swipe
  $(document).on('click', '#toast-container .toast', function() {
    COPO.utility.fadeUp(this)
  });

  // materialize tabs
  $('ul.tabs').tabs();

  // Attachinary init
  $('.attachinary-input').attachinary()
  // Event listeners
  setup();

  // dodgy hack to fix the multiple sidenav problem
  // works by deleting and recreating the nav dom node
  // inspired by this attrocity:
  // https://github.com/Dogfalo/materialize/issues/1894
  (function () {
    var oldMenu = $('.button-collapse').remove()
    $('nav').prepend(oldMenu)
    $(".button-collapse").sideNav();
    $('.collapsible').collapsible();
  }());

  $('.scrollspy').scrollSpy();

});


function setup() {
  addEventListeners();
  responsiveVideo();
}

function addEventListeners() {
  addClickListeners();
  addWindowResizeListeners();
}

function addClickListeners() {
  $(".landing-section .start-btn").click(function(e) {
    var offset = $(".landing-section.splash").height();
    $("body").animate({ scrollTop: offset });
  });
}

function addWindowResizeListeners() {
  $(window).resize(function(e) {
    responsiveVideo();
  });
}

function responsiveVideo() {
  var ratio = 1920/1080;
  var $h = $(".promo").height();
  var $w = $(".promo").width();
  var rRatio = $w/$h;

  if(rRatio < ratio) {
    // Aspect ratio is lower than 16:9
    $(".promo video").css({
      width: 'auto',
      height: '100%'
    });
  }else{
    // Aspect ratio is higher than 16:9
    $(".promo video").css({
      width: '100%',
      height: 'auto'
    });
  }
}
