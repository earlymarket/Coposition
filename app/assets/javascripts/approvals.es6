$(document).on('page:change', function() {
  if (($(".c-approvals.a-apps").length === 1) || ($(".c-approvals.a-friends").length === 1)) {
    const U  = window.COPO.utility;
    const M  = window.COPO.maps;

    $('.tooltipped').tooltip({delay: 50});
    U.gonFix();
    var page = ($(".c-approvals.a-apps").length === 1 ? 'apps' : 'friends')
    COPO.permissionsTrigger.initTrigger(page)
    COPO.permissions.initSwitches(page, gon.current_user_id, gon.permissions)
    M.initMap();
    M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);

    if(gon.friends.length){
      let clusters = M.arrayToCluster(gon.friends, M.makeMapPin);
      clusters.eachLayer((marker) => {
        marker.on('click', function (e) {
          M.panAndW3w.call(this, e)
        });
        marker.on('mouseover', (e) => {
          if(!marker._popup) {
            addPopup(marker);
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

    function addPopup (marker) {
      let user    = marker.options.user;
      let name    = U.friendsName(user);
      let date    = new Date(marker.options.lastCheckin.created_at).toUTCString();
      let address = U.commaToNewline(marker.options.lastCheckin.address) || marker.options.lastCheckin.fogged_area;
      let content = `
      <h2>${ name } <a href="./friends/${user.slug}" title="Device info">
        <i class="material-icons tiny">perm_device_information</i>
        </a></h2>
      <div class="address">${ address }</div>
      Checked in: ${ date }`
      marker.bindPopup(content, { offset: [0, -38] } );
    }
  }
})
