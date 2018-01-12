$(document).on('page:change', function() {
  if (window.COPO.utility.currentPage('friends', 'show')) {
    const U = window.COPO.utility;
    const M = window.COPO.maps;
    U.setActivePage('friends')
    U.gonFix();
    M.initMap();
    M.initControls(['locate', 'w3w', 'fullscreen', 'layers']);
    gon.checkins.length ? M.initMarkers(gon.checkins) : $('#map-overlay').removeClass('hide');

    $('.center-map').on('click', function() {
      const device_id = this.dataset.device;
      const checkin = gon.checkins.find((checkin) => checkin.device_id.toString() === device_id);
      if(checkin) {
        U.scrollTo('#quicklinks', 200);
        setTimeout(() => M.centerMapOn(checkin.lat, checkin.lng), 200);
      }
    });
  }
});
