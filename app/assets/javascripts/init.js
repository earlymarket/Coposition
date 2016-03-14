$(document).on('ready page:change', function() {
  // Materialize initialization
  // materialize dropdown menu init
  $(".dropdown-button").dropdown({
    hover: true,
    belowOrigin: true
  });

  // materialize accordion init
  $('.collapsible').collapsible();

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

  // Event listeners
  setup();
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
  $(".landing-section .start-btn").click(function(e){
    var offset = $(".landing-section.splash").height();
    $("body").animate({ scrollTop: offset });
  });
}

function addWindowResizeListeners(){
  $(window).resize(function(e) {
    responsiveVideo();
  });
}

function responsiveVideo(){
  var ratio = 1920/1080;
  var $h = $("#promo").height();
  var $w = $("#promo").width();
  var rRatio = $w/$h;

  if(rRatio < ratio){
    // Aspect ratio is lower than 16:9
    $(".parallax-container #promo video").css({
      width: 'auto',
      height: '100%'
    });
  }else{
    // Aspect ration is higher than 16:9
    $(".parallax-container #promo video").css({
      width: '100%',
      height: 'auto'
    });
  }
}
