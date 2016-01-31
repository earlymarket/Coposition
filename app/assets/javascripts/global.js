/*global utility toastr:true*/

$(document).on('page:fetch', function() {
  utility.animations.exitPage();
});



// Potentially remove
toastr.options = {
  "closeButton": false,
  "debug": false,
  "newestOnTop": false,
  "progressBar": false,
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
  "hideMethod": "fadeOut",
  "onShown": function(){
    toastrOffset();
  }
};

$(document).scroll(function() {
  toastrOffset();
});

function toastrOffset(){
  var offset = 64 - $(document).scrollTop() + 10;
  if ($(document).scrollTop() >= 64){
    $(".toast-top-right").css('top', '10px');
  } else {
    $(".toast-top-right").css('top', offset + 'px');
  }
}