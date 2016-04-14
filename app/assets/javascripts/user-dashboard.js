$(document).on('page:change', function() {
  if ($(".c-dashboards.a-show").length === 1) {
    COPO.maps.initMap();
    map.fitWorld();

    $.each(gon.friends, function(i,friend){

      var checkin = friend.lastCheckin
      if(checkin){
        var friendIcon = L.icon({iconUrl: COPO.utility.avatarUrl(friend.userinfo.avatar, {width: 30, height: 30})
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
