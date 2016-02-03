/*global utility toastr:true*/
$.fn.isOnScreen = function(){
    var element = this.get(0);
    var bounds = element.getBoundingClientRect();
    console.log(bounds.top, bounds.bottom, window.innerHeight);
    return bounds.top < window.innerHeight && bounds.bottom > 0;
};
