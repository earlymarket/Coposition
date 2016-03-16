$(document).on('page:change', function() {
  if ($(".c-friends.a-show_device").length === 1) {
    L.mapbox.accessToken = 'pk.eyJ1IjoiZ2FyeXNpdSIsImEiOiJjaWxjZjN3MTMwMDZhdnNtMnhsYmh4N3lpIn0.RAGGQ0OaM81HVe0OiAKE0w';
    var map = L.mapbox.map('map', 'mapbox.light', {maxZoom: 18} );

    COPO.maps.initMarkers(map);
  }
});

