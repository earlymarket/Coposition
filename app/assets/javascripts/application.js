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

// -- Libs from gems --

//= require materialize
//= require twitter/typeahead
//= require lodash
//= require moment

// -- Misc vendor libs --

//= require mustache
//= require jquery.mustache
//= require animateCSS.min.js
//= require cloudinary
//= require attachinary
//= require zeroclipboard
//= require nouislider.min.js
//= require ion.rangeSlider.min.js

// -- Mapbox stuff --
//= require mapbox
//= require leaflet.markercluster
//= require L.Control.Locate.min
//= require control.w3w

// -- Run every page

//= require utility
//= require navbar
//= require init
//= require cleanup
//= require charts
//= require maps
//= require permissions
//= require slider
//= require dateRange

// I've put require_tree back in. Any js where the load order isn't important doesn't need to be specified.
//= require_tree .
