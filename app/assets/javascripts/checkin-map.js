function renderMap(removeId){

  if(removeId) {
    var removeThis = checkins.map(function(checkin) { return checkin.id}).indexOf(removeId);
    checkins.splice(removeThis, 1);
  }

  if(checkins.length === 0) {
    $('#map').empty();
    var placeholder = '<h1 class="white-text valign">No checkins to display<i style="font-size: 4.2rem;" class="material-icons">place</i></h1>';
    $('#map').append(placeholder);
  } else {

    var lastCheckin = {lat: checkins[0].lat, lng: checkins[0].lng};
    var bounds = new google.maps.LatLngBounds();
    var markers = []

    var map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: lastCheckin
    });

    $.each(checkins, function(i, checkin){
      position = {lat: checkin.lat, lng: checkin.lng}
      marker = new google.maps.Marker({
        position: position,
        map: map
      });
      bounds.extend(marker.getPosition())
      markers.push(marker)
    })

    map.fitBounds(bounds)

    var options = {
      minimumClusterSize: 1,
      zoomOnClick: false
    };

    var mc = new MarkerClusterer(map, markers, options)

    var listener = google.maps.event.addListenerOnce(map, "idle", function() {
      if (map.getZoom() > 16) map.setZoom(16);
    })
  }
}
