$(document).on('page:before-unload', function() {
  if($('#sidenav-overlay')) $("#sidenav-overlay").trigger("click");
})
