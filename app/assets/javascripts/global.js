/*global utility toastr:true*/

$(document).on('page:change', function(){
  setup()
});

$(document).on('page:fetch', function() {
  utility.animations.exitPage()
});


function setup() {
  animateThings()
  addEventListeners()
}

function addEventListeners() {
  addClickListeners()
}


function animateThings() {
  utility.animations.enterPage()
  setupTextillate()
}


function setupTextillate() {
  $('.tlt').textillate(
    {
      in: {
        delayScale: 0.9
      }
    }
  );
}

function addClickListeners() {
  $(".close").click(function(e){
    utility.animations.removeEl($(e.currentTarget).parent())
  });
}

toastr.options = {
  "closeButton": false,
  "debug": false,
  "newestOnTop": false,
  "progressBar": true,
  "positionClass": "toast-top-right",
  "preventDuplicates": false,
  "onclick": null,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "6000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}