window.COPO = window.COPO || {};
window.COPO.permissions = {
  check_disabled: function(){
    $('[data-switch=disallowed]').each(function(){
      var permission_id =  $(this).data().permission;
      if ($(this).find('input').prop('checked')){
        COPO.permissions.toggle_switches_disabled(permission_id);
      } else {
        COPO.permissions.icon_toggle('disallowed', permission_id);
      }
    });
  },

  check_bypass: function(){
    ['bypass_fogging', 'bypass_delay'].forEach(function(attribute){
      $("[data-switch='"+attribute+"']").each(function(){
        if ($(this).find('input').prop('checked')){
          var permission_id =  $(this).data().permission;
          COPO.permissions.icon_toggle(attribute, permission_id);
        }
      });
    })
  },

  set_globals: function(){
    if (gon.devices) {
      gon.devices.forEach(function(device){
        var permissions = _.filter(gon.permissions, _.matchesProperty('device_id', device.id))
        $("div[data-device='"+device.id+"']").each(function(){
          var switches_statuses = [];
          var switch_type = $(this).data().switch;
          permissions.forEach(function(permission){
            var $switch = $("div[data-permission='"+permission.id+"'][data-switch='"+switch_type+"']")
            switches_statuses.push($switch.find('input').prop("checked"))
          })
          var new_global_state = _.every(switches_statuses)
          $(this).find('input').prop('checked', new_global_state);
          if (switch_type === "disallowed") {
            var disallowed_state = $(this).find('input').prop("checked");
            $("div[data-device='"+device.id+"'][data-switch=last_only]").find('input').prop("checked", false);
            element = $("div[data-device='"+ device.id +"'].disable").find('input');
            element.prop("disabled", disallowed_state);
          }
        })
      })
    }
  },

  switch_change:function(){
    $(".permission-switch").change(function( event ) {
      var attribute = $(this).data().attribute;
      var switch_type = $(this).data().switch;
      var permission_id =  $(this).data().permission;
      COPO.permissions.icon_toggle(switch_type, permission_id);
      var permission = _.find(gon.permissions, _.matchesProperty('id', permission_id));
      var device_id = permission['device_id'];

      if (permission[attribute].constructor === Boolean){
        permission[attribute] = !permission[attribute]
      } else {
        permission[attribute] = COPO.permissions.new_privilege(permission[attribute], switch_type);
      }

      if (switch_type === "disallowed") {
        $("div[data-permission='"+permission_id+"'][data-switch=last_only]").find('input').prop("checked", false);
        COPO.permissions.toggle_switches_disabled(permission_id);
      }
      COPO.permissions.set_globals();

      $.ajax({
        url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission_id+"",
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

  global_change:function(){
    $(".global").change(function( event ) {
      var global_status = $(this).find('input').prop("checked");
      var switch_type = $(this).data().switch;
      var device_id = $(this).data().device;
      var permissions = _.filter(gon.permissions, _.matchesProperty('device_id', device_id));

      permissions.forEach(function(permission){
        var $switch = $("div[data-permission='"+permission.id+"'][data-switch='"+switch_type+"']")
        var current_status = $switch.find('input').prop("checked")
        if (global_status !== current_status) {
          $switch.find('input').prop("checked", global_status);
          $switch.trigger("change");
        }
      })
    })
  },

  toggle_switches_disabled: function(permission_id){
    element = $("div[data-permission='"+ permission_id +"'].disable").find('input');
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
  }
};
