// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require turbolinks
//= require turbolinks-compatibility

// -- Libs from gems --

//= require cloudinary
//= require attachinary

// -- Misc vendor libs --

//= require lodash/lodash.min
//= require moment/min/moment.min
//= require jquery-mustache-earlymarket/jquery.mustache
//= require mustache/mustache.min
//= require materialize-css/dist/js/materialize.min
//= require typeahead.js/dist/typeahead.bundle.min
//= require clipboard/dist/clipboard.min
//= require slick-carousel/slick/slick.min
//= require sweetalert/dist/sweetalert.min
//= require datetimepicker-earlymarket/dist/DateTimePicker
//= require smooch/lib/index

// STILL more up to date version
//= require nouislider.min

// -- Mapbox stuff --
//= require leaflet/dist/leaflet
//= require mapbox.js/src/mapbox
//= require leaflet.markercluster/dist/leaflet.markercluster.js
//= require leaflet.locatecontrol/dist/L.Control.Locate.min
//= require leaflet-fullscreen/dist/Leaflet.fullscreen.min
//= require control.w3w

// I've put require_tree back in. Any js where the load order isn't important doesn't need to be specified.
//= require_tree .
