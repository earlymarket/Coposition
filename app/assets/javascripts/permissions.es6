window.COPO = window.COPO || {};
window.COPO.permissions = {
  initSwitches: function(page, user, permissions){
    COPO.permissions.setMasters(page, user, permissions);
    COPO.permissions.masterChange(page, user, permissions);
    COPO.permissions.switchChange(page, user, permissions);
    COPO.permissions.checkDisabled(user);
    COPO.permissions.checkBypass(user);
  },

  switchesOff: function(){
    $(".permission-switch").off("change");
    $(".master").off("change");
  },

  checkDisabled: function(user){
    $('[data-switchtype=disallowed].permission-switch').each(function(){
      const P_SWITCH = new PermissionSwitch(user, $(this))
      if (P_SWITCH.checked){
        P_SWITCH.changeDisableSwitches(true);
      } else {
        $('#accessIcon'+P_SWITCH.id).css('display', 'none');
      }
    });
  },

  checkBypass: function(user){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $(`[data-switchtype=${attribute}]`).each(function(){
        const P_SWITCH = new PermissionSwitch(user, $(this))
        if (P_SWITCH.checked){
          if (P_SWITCH.switchtype === 'bypass_fogging'){
            $('#fogIcon'+P_SWITCH.id).css('display', 'none');
          } else {
            $('#delayIcon'+P_SWITCH.id).css('display', 'none');
          }
        }
      });
    })
  },

  setMasters: function(page, user, gonPermissions){
    const gonType = (page === 'devices' ? 'devices' : 'approved')
    if (gon[gonType]) {
      gon[gonType].forEach(function(permissionable){
        const ID_TYPE = (page === 'devices' ? 'device_id' : 'permissible_id')
        $(`div[data-id=${permissionable.id}].master`).each(function(){
          const M_SWITCH = new MasterSwitch(user, $(this), gonPermissions, ID_TYPE, page)
          M_SWITCH.setState();
        })
      })
    }
  },

  switchChange:function(page, user, gonPermissions){
    $(".permission-switch").change(function() {
      const P_SWITCH = new LocalSwitch(user, $(this), gonPermissions, page)
      P_SWITCH.toggleSwitch();
      COPO.permissions.setMasters(page, user, gonPermissions);
    })
  },

  masterChange:function(page, user, gonPermissions){
    $(".master").change(function() {
      const ID_TYPE = (page === 'devices' ? 'device_id' : 'permissible_id')
      const M_SWITCH = new MasterSwitch(user, $(this), gonPermissions, ID_TYPE, page)
      M_SWITCH.toggleSwitch();
      M_SWITCH.setState();
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
