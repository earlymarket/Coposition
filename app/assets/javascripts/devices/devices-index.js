$(document).on('page:change', function() {
  if ($(".c-devices.a-index").length === 1) {
    COPO.permissions.switch_change();
    COPO.permissions.check_disabled();
  }
})
