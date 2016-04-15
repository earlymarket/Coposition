$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.maps.initMap();
    // map.fitWorld();
    var markers = gon.friends.slice();
    markers.push(JSON.parse(JSON.stringify(gon.current_user)));

    var markerClusterGroup = new L.MarkerClusterGroup();
    $.each(markers, function(i,person){

      var checkin = person.lastCheckin
      if(checkin){
        var public_id = person.userinfo.avatar.public_id;
        var icon =  L.icon({
          iconUrl: $.cloudinary.url(public_id, {format: 'png', transformation: 'map-pin'}),
          iconSize: [36,52],
          iconAnchor: [18,49]
        })
        markerClusterGroup.addLayer(L.marker([checkin.lat, checkin.lng], {icon: icon, title: person.userinfo.username}))
      }

    })

    map.addLayer(markerClusterGroup);
    map.fitBounds(markerClusterGroup);

    google.charts.setOnLoadCallback(function() {
       COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
