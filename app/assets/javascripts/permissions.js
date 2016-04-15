window.COPO = window.COPO || {};
window.COPO.permissions = {
  check_disabled: function(){
    $('[data-switch=disallowed].permission-switch').each(function(){
      var permission_id =  $(this).data().id;
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
          var permission_id =  $(this).data().id;
          COPO.permissions.icon_toggle(attribute, permission_id);
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
    $(".permission-switch").change(function( event ) {
      var attribute = $(this).data().attribute;
      var switch_type = $(this).data().switch;
      var permission_id =  $(this).data().id;
      COPO.permissions.icon_toggle(switch_type, permission_id);
      var permission = _.find(gon.permissions, _.matchesProperty('id', permission_id));
      var device_id = permission['device_id'];

      if (permission[attribute].constructor === Boolean){
        permission[attribute] = !permission[attribute]
      } else {
        permission[attribute] = COPO.permissions.new_privilege(permission[attribute], switch_type);
      }

      if (switch_type === "disallowed") {
        $("div[data-id='"+permission_id+"'][data-switch=last_only].permission-switch").find('input').prop("checked", false);
        COPO.permissions.toggle_switches_disabled(permission_id);
      }
      COPO.permissions.set_masters(permissionables);

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

  master_change:function(permissionables){
    $(".master").change(function( event ) {
      var $master = $(this)
      var master_checked = $master.find('input').prop("checked");
      var master_type = $master.data().switch;
      var id = $master.data().id;
      var property = (permissionables === 'devices' ? 'device_id' : 'permissible_id')
      var permissions = _.filter(gon.permissions, _.matchesProperty(property, id));
      permissions.forEach(function(permission){
        var $switch = $("div[data-id='"+permission.id+"'][data-switch='"+master_type+"'].permission-switch")
        var switch_type = $switch.data().switch;
        var checked = $switch.find('input').prop("checked")
        var disabled = $switch.find('input').prop("disabled")
        if ((disabled && switch_type === 'last_only')){
          $master.find('input').prop("checked", false)
        } else if (master_checked !== checked) {
          $switch.find('input').prop("checked", master_checked);
          $switch.trigger("change", [permissionables]);
        }
      })
    })
  },

  toggle_switches_disabled: function(permission_id){
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
  }
};
