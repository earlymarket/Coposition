$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.maps.initMap();
    map.fitWorld();

    $.each(gon.friends, function(i,friend){

      var checkin = friend.lastCheckin
      if(checkin){
        var public_id = friend.userinfo.avatar.public_id;
        var friendIcon = L.icon({
          iconUrl: $.cloudinary.url(public_id, {format: 'png', transformation: 'map-pin'}),
          iconSize: [36,52],
          iconAnchor: [18,49]
        })
        L.marker([checkin.lat, checkin.lng], {icon: friendIcon, title: friend.userinfo.username}).addTo(map)
      }

    })

    google.charts.setOnLoadCallback(function() {
       COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
    $(window).resize(function(){
      COPO.charts.drawBarChart(gon.weeks_checkins, '270');
    });
  }
});
