window.COPO = window.COPO || {};
window.COPO.permissions = {
  check_disabled: function(){
    $('[data-switch=disallowed]').each(function(){
      if ($(this).find('input').prop('checked')){
        var permission_id =  $(this).data().permission;
        COPO.permissions.toggle_switches_disabled(permission_id);
      }
    });
  },

  switch_change:function(){
    $(".switch").change(function( event ) {
      var permission_id = $(this).data().permission;
      var attribute = $(this).data().attribute;
      var switch_type = $(this).data().switch;

      var permission = $.grep(gon.permissions, function(perm){ return perm.id === permission_id; });
      permission = permission[0];
      permission[attribute] = COPO.permissions.new_state(permission[attribute], switch_type);
      var device_id = permission['device_id'];

      if (switch_type === "disallowed") {
        $("div[data-permission='"+permission_id+"'][data-switch=last_only]").find('input').prop("checked", false);
        COPO.permissions.toggle_switches_disabled(permission_id);
      }

      var data = COPO.permissions.set_data(attribute, permission[attribute]);
      $.ajax({
        url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission_id+"",
        type: 'PUT',
        data: { permission : data }
      });
    })
  },

  new_state: function(current_state, switch_type){
    if(current_state === "disallowed"){
      return "complete"
    } else if(switch_type === "disallowed"){
      return "disallowed"
    } else if(current_state === "complete"){
      return "last_only"
    } else if(current_state === "last_only"){
      return "complete"
    } else {
      return !current_state
    }
  },

  toggle_switches_disabled: function(permission_id){
    element = $("div[data-permission='"+ permission_id +"'].disable").find('input');
    element.prop("disabled", !element.prop("disabled"));
  },

  set_data: function(attribute, value){
    if (attribute === 'privilege'){
      return { privilege: value };
    } else if (attribute === 'bypass_fogging'){
      return { bypass_fogging: value };
    } else {
      return { bypass_delay: value };
    }
  }
};

