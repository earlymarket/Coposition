window.COPO = window.COPO || {};
window.COPO.permissions = {
  initSwitches(page, user, permissions) {
    COPO.permissions.setMasters(page, user, permissions);
    COPO.permissions.masterChange(page, user, permissions);
    COPO.permissions.switchChange(page, user, permissions);
  },

  switchesOff() {
    $(".permission-switch").off("change");
    $(".master").off("change");
  },

  setMasters(page, user, gonPermissions) {
    const gonVariable = (page === 'devices' ? 'devices' : 'approved')
    if (gon[gonVariable]) {
      gon[gonVariable].forEach(function(permissionable){
        const ID_TYPE = (page === 'devices' ? 'device_id' : 'permissible_id')
        $(`div[data-id=${permissionable.id}].master`).each(function(){
          const M_SWITCH = new MasterSwitch(user, $(this), gonPermissions, ID_TYPE, page)
          M_SWITCH.setState();
        })
      })
    }
  },

  switchChange(page, user, gonPermissions) {
    $(".permission-switch").change(function() {
      const P_SWITCH = new LocalSwitch(user, $(this), gonPermissions, page)
      P_SWITCH.toggleSwitch();
      COPO.permissions.setMasters(page, user, gonPermissions);
    })
  },

  masterChange(page, user, gonPermissions) {
    $(".master").change(function() {
      const ID_TYPE = (page === 'devices' ? 'device_id' : 'permissible_id')
      const M_SWITCH = new MasterSwitch(user, $(this), gonPermissions, ID_TYPE, page)
      M_SWITCH.toggleSwitch();
      M_SWITCH.setState();
    })
  },
};
