window.COPO = window.COPO || {};
window.COPO.permissions = {
  initSwitches: function(permissionableType, user, permissions){
    COPO.permissions.setMasters(permissionableType, user, permissions);
    COPO.permissions.masterChange(permissionableType, user, permissions);
    COPO.permissions.switchChange(permissionableType, user, permissions);
    COPO.permissions.checkDisabled(user);
    COPO.permissions.checkBypass(user);
  },

  switchesOff: function(){
    $(".permission-switch").off("change");
    $(".master").off("change");
  },

  checkDisabled: function(user){
    $('[data-switchtype=disallowed].permission-switch').each(function(){
      const PSWITCH = new PermissionSwitch(user, $(this))
      if (PSWITCH.checked){
        PSWITCH.changeDisableSwitches(true);
      } else {
        $('#accessIcon'+PSWITCH.id).css('display', 'none');
        //COPO.permissions.iconToggle('disallowed', PSWITCH.id);
      }
    });
  },

  checkBypass: function(user){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $(`[data-switchtype=${attribute}]`).each(function(){
        const PSWITCH = new PermissionSwitch(user, $(this))
        if (PSWITCH.checked){
          if (PSWITCH.switchtype === 'bypass_fogging'){
            $('#fogIcon'+PSWITCH.id).css('display', 'none');
          } else {
            $('#delayIcon'+PSWITCH.id).css('display', 'none');
          }
        }
      });
    })
  },

  setMasters: function(permissionableType, user, gonPermissions){
    if (gon[permissionableType]) {
      gon[permissionableType].forEach(function(permissionable){
        const IDTYPE = (permissionableType === 'devices' ? 'device_id' : 'permissible_id')
        $(`div[data-id=${permissionable.id}].master`).each(function(){
          const MSWITCH = new MasterSwitch(user, $(this), gonPermissions, IDTYPE)
          MSWITCH.setState();
        })
      })
    }
  },

  switchChange:function(permissionableType, user, gonPermissions){
    $(".permission-switch").change(function() {
      const PSWITCH = new LocalSwitch(user, $(this), gonPermissions)
      PSWITCH.toggleSwitch();
      COPO.permissions.setMasters(permissionableType, user, gonPermissions);
    })
  },

  masterChange:function(permissionableType, user, gonPermissions){
    $(".master").change(function() {
      const IDTYPE = (permissionableType === 'devices' ? 'device_id' : 'permissible_id')
      const MSWITCH = new MasterSwitch(user, $(this), gonPermissions, IDTYPE)
      MSWITCH.toggleSwitch();
      MSWITCH.setState();
    })
  },

  iconToggle: function(switchtype, permissionId){
    if (switchtype === 'bypass_fogging'){
      $('#fogIcon'+permissionId).toggle();
    } else if (switchtype === 'bypass_delay'){
      $('#delayIcon'+permissionId).toggle();
    } else if (switchtype === 'disallowed'){
      $('#accessIcon'+permissionId).toggle();
    }
  }
};
