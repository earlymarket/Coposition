window.COPO = window.COPO || {};
window.COPO.permissions = {
  check_disabled: function(){
    $('[data-switch=disallowed].permission-switch').each(function(){
      var permission_switch = COPO.permissions.permission_switch(this);
      if (permission_switch.checked){
        COPO.permissions.toggle_switches_disabled(permission_switch.id);
      } else {
        COPO.permissions.icon_toggle('disallowed', permission_switch.id);
      }
    });
  },

  check_bypass: function(){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $("[data-switch='"+attribute+"']").each(function(){
        var permission_switch = COPO.permissions.permission_switch(this);
        if (permission_switch.checked){
          COPO.permissions.icon_toggle(attribute, permission_switch.id);
        }
      });
    })
  },

  set_masters: function(permissionables){
    if (gon[permissionables]) {
      gon[permissionables].forEach(function(permissionable){
        var property = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
        var permissions = _.filter(gon.permissions, _.matchesProperty(property, permissionable.id))
        $("div[data-id='"+permissionable.id+"'].master").each(function(){
          var switches_checked = [];
          var switch_type = $(this).data().switch;
          permissions.forEach(function(permission){
            var $switch = $("div[data-id='"+permission.id+"'][data-switch='"+switch_type+"'].permission-switch")
            switches_checked.push($switch.find('input').prop("checked"))
          })
          var new_master_checked_state = _.every(switches_checked)
          $(this).find('input').prop('checked', new_master_checked_state);
          if (switch_type === "disallowed") {
            $("div[data-id='"+permissionable.id+"'][data-switch=last_only].master").find('input').prop("checked", false);
            element = $("div[data-id='"+ permissionable.id +"'].disable.master").find('input');
            element.prop("disabled", new_master_checked_state);
          }
        })
      })
    }
  },

  switch_change:function(permissionables){
    $(".permission-switch").change(function() {
      var permission_switch = COPO.permissions.permission_switch(this);
      var attribute = permission_switch.attribute;
      var permission = _.find(gon.permissions, _.matchesProperty('id', permission_switch.id));

      COPO.permissions.icon_toggle(permission_switch.switch_type, permission.id);

      if (attribute === 'privilege'){
        permission[attribute] = COPO.permissions.new_privilege(permission[attribute], permission_switch.switch_type);
      } else {
        permission[attribute] = !permission[attribute]
      }

      if (permission_switch.switch_type === "disallowed") {
        COPO.permissions.toggle_switches_disabled(permission.id);
      }
      COPO.permissions.set_masters(permissionables);

      $.ajax({
        url: "/users/"+gon.current_user_id+"/devices/"+permission.device_id+"/permissions/"+permission.id+"",
        type: 'PUT',
        data: { permission: permission }
      });
    })
  },

  icon_toggle: function(switch_type, permission_id){
    if (switch_type === 'bypass_fogging'){
      $('#fogIcon'+permission_id).toggle();
    } else if (switch_type === 'bypass_delay'){
      $('#delayIcon'+permission_id).toggle();
    } else if (switch_type === 'disallowed'){
      $('#accessIcon'+permission_id).toggle();
    }
  },

  master_change:function(permissionables){
    $(".master").change(function() {
      var master_switch = COPO.permissions.permission_switch(this)
      var property = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
      var permissions = _.filter(gon.permissions, _.matchesProperty(property, master_switch.id));
      permissions.forEach(function(permission){
        var $switch = $("div[data-id='"+permission.id+"'][data-switch='"+master_switch.switch_type+"'].permission-switch")
        var permission_switch = COPO.permissions.permission_switch($switch)
        if ((permission_switch.disabled && permission_switch.switch_type === 'last_only')){
          $(this).find('input').prop("checked", false)
        } else if (master_switch.checked !== permission_switch.checked) {
          $switch.find('input').prop("checked", master_switch.checked);
          $switch.trigger("change", [permissionables]);
        }
      })
    })
  },

  toggle_switches_disabled: function(permission_id){
    $("div[data-id='"+permission_id+"'][data-switch=last_only].permission-switch").find('input').prop("checked", false);
    element = $("div[data-id='"+ permission_id +"'].disable").find('input');
    element.prop("disabled", !element.prop("disabled"));
  },

  new_privilege: function(current_privilege, switch_type){
    if(current_privilege === "disallowed"){
      return "complete"
    } else if(switch_type === "disallowed"){
      return "disallowed"
    } else if(current_privilege === "complete"){
      return "last_only"
    } else if(current_privilege === "last_only"){
      return "complete"
    }
  },

  permission_switch: function(permission_switch){
    return {
      id: $(permission_switch).data().id,
      attribute: $(permission_switch).data().attribute,
      switch_type: $(permission_switch).data().switch,
      checked: $(permission_switch).find('input').prop('checked'),
      disabled: $(permission_switch).find('input').prop('disabled')
    }
  }
};
