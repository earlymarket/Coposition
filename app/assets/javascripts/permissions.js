window.COPO = window.COPO || {};
window.COPO.permissions = {
  checkDisabled: function(){
    $('[data-switch=disallowed].permission-switch').each(function(){
      var permissionSwitch = COPO.permissions.permissionSwitch(this);
      if (permissionSwitch.checked){
        COPO.permissions.toggleSwitchesDisabled(permissionSwitch.id);
      } else {
        COPO.permissions.iconToggle('disallowed', permissionSwitch.id);
      }
    });
  },

  checkBypass: function(){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $("[data-switch='"+attribute+"']").each(function(){
        var permissionSwitch = COPO.permissions.permissionSwitch(this);
        if (permissionSwitch.checked){
          COPO.permissions.iconToggle(attribute, permissionSwitch.id);
        }
      });
    })
  },

  setMasters: function(permissionables, gonPermissions){
    if (gon[permissionables]) {
      gon[permissionables].forEach(function(permissionable){
        var property = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
        var permissions = _.filter(gonPermissions, _.matchesProperty(property, permissionable.id))

        $("div[data-id='"+permissionable.id+"'].master").each(function(){
          var switchesChecked = [];
          var switchType = $(this).data().switch;
          permissions.forEach(function(permission){
            var $switch = $("div[data-id='"+permission.id+"'][data-switch='"+switchType+"'].permission-switch")
            switchesChecked.push($switch.find('input').prop("checked"))
          })
          var newMasterCheckedState = _.every(switchesChecked)
          $(this).find('input').prop('checked', newMasterCheckedState);

          if (switchType === "disallowed") {
            $("div[data-id='"+permissionable.id+"'][data-switch=last_only].master").find('input').prop("checked", false);
            element = $("div[data-id='"+ permissionable.id +"'].disable.master").find('input');
            element.prop("disabled", newMasterCheckedState);
          }
        })
      })
    }
  },

  switchChange:function(permissionables, gonPermissions){
    $(".permission-switch").change(function() {
      var permissionSwitch = COPO.permissions.permissionSwitch(this);
      var attribute = permissionSwitch.attribute;
      var permission = _.find(gonPermissions, _.matchesProperty('id', permissionSwitch.id));

      COPO.permissions.iconToggle(permissionSwitch.switchType, permission.id);

      if (attribute === 'privilege'){
        permission[attribute] = COPO.permissions.newPrivilege(permission[attribute], permissionSwitch.switchType);
      } else {
        permission[attribute] = !permission[attribute]
      }

      if (permissionSwitch.switchType === "disallowed") {
        COPO.permissions.toggleSwitchesDisabled(permission.id);
      }
      COPO.permissions.setMasters(permissionables, gonPermissions);

      $.ajax({
        url: "/users/"+gon.current_user_id+"/devices/"+permission.device_id+"/permissions/"+permission.id+"",
        type: 'PUT',
        data: { permission: permission }
      });
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
  },

  masterChange:function(permissionables, gonPermissions){
    $(".master").change(function() {
      var $master = $(this)
      var masterSwitch = COPO.permissions.permissionSwitch(this)
      var property = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
      var permissions = _.filter(gonPermissions, _.matchesProperty(property, masterSwitch.id));
      permissions.forEach(function(permission){
        var $switch = $("div[data-id='"+permission.id+"'][data-switch='"+masterSwitch.switchType+"'].permission-switch")
        var permissionSwitch = COPO.permissions.permissionSwitch($switch)
        if ((permissionSwitch.disabled && permissionSwitch.switchType === 'last_only')){
          $master.find('input').prop("checked", false)
        } else if (masterSwitch.checked !== permissionSwitch.checked) {
          $switch.find('input').prop("checked", masterSwitch.checked);
          $switch.trigger("change", [permissionables, gonPermissions]);
        }
      })
    })
  },

  toggleSwitchesDisabled: function(permissionId){
    $("div[data-id='"+permissionId+"'][data-switch=last_only].permission-switch").find('input').prop("checked", false);
    element = $("div[data-id='"+ permissionId +"'].disable").find('input');
    element.prop("disabled", !element.prop("disabled"));
  },

  newPrivilege: function(currentPrivilege, switchType){
    if(currentPrivilege === "disallowed"){
      return "complete"
    } else if(switchType === "disallowed"){
      return "disallowed"
    } else if(currentPrivilege === "complete"){
      return "last_only"
    } else if(currentPrivilege === "last_only"){
      return "complete"
    }
  },

  permissionSwitch: function(permissionSwitch){
    return {
      id: $(permissionSwitch).data().id,
      attribute: $(permissionSwitch).data().attribute,
      switchType: $(permissionSwitch).data().switch,
      checked: $(permissionSwitch).find('input').prop('checked'),
      disabled: $(permissionSwitch).find('input').prop('disabled')
    }
  }
};
