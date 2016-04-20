window.COPO = window.COPO || {};
window.COPO.permissions = {
  initSwitches: function(permissionableType, user, permissions){
    COPO.permissions.setMasters(permissionableType, user, permissions);
    COPO.permissions.masterChange(permissionableType, user, permissions);
    COPO.permissions.switchChange(permissionableType, user, permissions);
    COPO.permissions.checkDisabled(user);
    COPO.permissions.checkBypass(user);
  },

  checkDisabled: function(user){
    $('[data-switch=disallowed].permission-switch').each(function(){
      let pSwitch = new Switch(user, $(this))
      if (pSwitch.checked){
        pSwitch.changeDisableSwitches(true);
      } else {
        COPO.permissions.iconToggle('disallowed', pSwitch.id);
      }
    });
  },

  checkBypass: function(user){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $(`[data-switch=${attribute}]`).each(function(){
        let pSwitch = new Switch(user, $(this))
        if (pSwitch.checked){
          COPO.permissions.iconToggle(attribute, pSwitch.id);
        }
      });
    })
  },

  setMasters: function(permissionableType, user, gonPermissions){
    if (gon[permissionableType]) {
      gon[permissionableType].forEach(function(permissionable){
        let idType = (permissionableType === 'devices' ? 'device_id' : 'permissible_id')
        $(`div[data-id=${permissionable.id}].master`).each(function(){
          let mSwitch = new MasterSwitch(user, $(this), gonPermissions, idType)
          mSwitch.setState();
        })
      })
    }
  },

  switchChange:function(permissionableType, user, gonPermissions){
    $(".permission-switch").change(function() {
      let pSwitch = new PermissionSwitch(user, $(this), gonPermissions)
      pSwitch.toggleSwitch();
      COPO.permissions.setMasters(permissionableType, user, gonPermissions);
    })
  },

  masterChange:function(permissionableType, user, gonPermissions){
    $(".master").change(function() {
      let idType = (permissionableType === 'devices' ? 'device_id' : 'permissible_id')
      let mSwitch = new MasterSwitch(user, $(this), gonPermissions, idType)
      mSwitch.toggleSwitch();
      mSwitch.setState();
    })
  },

  iconToggle: function(switchType, permissionId){
    if (switchType === 'bypass_fogging'){
      $('#fogIcon'+permissionId).toggle();
    } else if (switchType === 'bypass_delay'){
      $('#delayIcon'+permissionId).toggle();
    } else if (switchType === 'disallowed'){
      $('#accessIcon'+permissionId).toggle();
    }
  }
};
