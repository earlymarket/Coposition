window.COPO = window.COPO || {};
window.COPO.permissions = {
  checkDisabled: function(){
    $('[data-switch=disallowed].permission-switch').each(function(){
      var pSwitch = new Switch(gon.current_user_id, $(this))
      if (pSwitch.checked){
        pSwitch.changeDisableSwitches(true);
      } else {
        COPO.permissions.iconToggle('disallowed', pSwitch.id);
      }
    });
  },

  checkBypass: function(){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $(`[data-switch=${attribute}]`).each(function(){
        var pSwitch = new Switch(gon.current_user_id, $(this))
        if (pSwitch.checked){
          COPO.permissions.iconToggle(attribute, pSwitch.id);
        }
      });
    })
  },

  setMasters: function(permissionables, gonPermissions){
    if (gon[permissionables]) {
      gon[permissionables].forEach(function(permissionable){
        var idType = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
        $(`div[data-id=${permissionable.id}].master`).each(function(){
          var mSwitch = new MasterSwitch(gon.current_user_id, $(this), gonPermissions, idType)
          mSwitch.setState();
        })
      })
    }
  },

  switchChange:function(permissionables, gonPermissions){
    $(".permission-switch").change(function() {
      var pSwitch = new PermissionSwitch(gon.current_user_id, $(this), gonPermissions)
      pSwitch.toggleSwitch();
      COPO.permissions.setMasters(permissionables, gonPermissions);
    })
  },

  masterChange:function(permissionables, gonPermissions){
    $(".master").change(function() {
      var idType = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
      var mSwitch = new MasterSwitch(gon.current_user_id, $(this), gonPermissions, idType)
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
