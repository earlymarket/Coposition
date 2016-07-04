$(document).on('page:change', function() {
  if (($(".c-approvals.a-apps").length === 1) || ($(".c-approvals.a-friends").length === 1)) {
    const U  = window.COPO.utility;
    const M  = window.COPO.maps;

    $('.tooltipped').tooltip({delay: 50});
    U.gonFix();
    const PAGE = ($(".c-approvals.a-apps").length === 1 ? 'apps' : 'friends')
    COPO.permissionsTrigger.initTrigger(PAGE)
    COPO.permissions.initSwitches(PAGE, gon.current_user_id, gon.permissions)

    if(gon.friends && gon.friends.length){
      $('.friends-index').removeClass('hide');
      M.initMap();
      M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
      let clusters = M.arrayToCluster(gon.friends, M.makeMapPin);
      clusters.eachLayer((marker) => {
        marker.on('click', function (e) {
          M.panAndW3w.call(this, e)
        });
        marker.on('mouseover', (e) => {
          if(!marker._popup) {
            M.friendPopup(marker);
          }
          COPO.maps.w3w.setCoordinates(e);
          marker.openPopup();
        });
      });
      map.addLayer(clusters);
      const BOUNDS = L.latLngBounds(
          _.compact(gon.friends.map(friend => friend.lastCheckin))
          .map(friend => L.latLng(friend.lat, friend.lng)))
      map.fitBounds(BOUNDS, {padding: [40, 40]})
    } else {
      $('#map-overlay').removeClass('hide');
    }

    $(document).on('page:before-unload', function(){
      COPO.permissions.switchesOff();
    })
  }
})
