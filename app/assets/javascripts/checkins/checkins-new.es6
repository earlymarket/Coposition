$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('checkins', 'new')) {
    navigator.geolocation.getCurrentPosition(function(position) {
      $("#checkin_lat").val(position.coords.latitude.toFixed(6))
      $("#checkin_lng").val(position.coords.longitude.toFixed(6))

      var latlon = position.coords.latitude + "," + position.coords.longitude;
      var img_url = "http://maps.googleapis.com/maps/api/staticmap?center=" + latlon + "&zoom=16&size=500x500";
      $("#mapholder").attr("src", img_url);
      $("#location").attr("value", latlon);
    });
  }
})
