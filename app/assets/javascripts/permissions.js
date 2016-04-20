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
      var pSwitch = new Switch(user, $(this))
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
        var pSwitch = new Switch(user, $(this))
        if (pSwitch.checked){
          COPO.permissions.iconToggle(attribute, pSwitch.id);
        }
      });
    })
  },

  setMasters: function(permissionables, user, gonPermissions){
    if (gon[permissionables]) {
      gon[permissionables].forEach(function(permissionable){
        var idType = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
        $(`div[data-id=${permissionable.id}].master`).each(function(){
          var mSwitch = new MasterSwitch(user, $(this), gonPermissions, idType)
          mSwitch.setState();
        })
      })
    }
  },

  switchChange:function(permissionables, user, gonPermissions){
    $(".permission-switch").change(function() {
      var pSwitch = new PermissionSwitch(user, $(this), gonPermissions)
      pSwitch.toggleSwitch();
      COPO.permissions.setMasters(permissionables, user, gonPermissions);
    })
  },

  masterChange:function(permissionables, user, gonPermissions){
    $(".master").change(function() {
      var idType = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
      var mSwitch = new MasterSwitch(user, $(this), gonPermissions, idType)
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
