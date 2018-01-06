$(document).on('ready page:change', function() {
  // Materialize initialization
  // materialize dropdown menu init
  $(".dropdown-button").dropdown({
    hover: true,
    belowOrigin: true
  });

  var isTouchDevice = navigator.maxTouchPoints
  if (L.Browser.chrome && L.Browser.touch && isTouchDevice) {
      L.Browser.pointer = false;
  }

  // COPO.smooch.initSmooch();

  // All modals should be initialized starting from 0.98
  $('.modal').modal();

  // We're calling this later now in the dodgy hack
  // // materialize accordion init
  $('.collapsible').collapsible({
    onOpen: function(el) {
      collapsible = el.find(".collapsible-header");

      if (collapsible.data("onopen")) {
        window[collapsible.data("onopen")]();
      }
    },
    onClose: function(el) {
      collapsible = el.find(".collapsible-header");

      if (collapsible.data("onclose")) {
        window[collapsible.data("onclose")]();
      }
    }
  });

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
  $('.attachinary-input').attachinary();
  // Event listeners

  $('.scrollspy').scrollSpy();

});
