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
      var attribute = $(this).data().attribute;
      var switch_type = $(this).data().switch;
      var permission_id =  $(this).data().permission;
      var permission = _.find(gon.permissions, _.matchesProperty('id', permission_id));
      var device_id = permission['device_id'];
      permission[attribute] = COPO.permissions.new_privilege(permission[attribute], switch_type);

      if (switch_type === "disallowed") {
        $("div[data-permission='"+permission_id+"'][data-switch=last_only]").find('input').prop("checked", false);
        COPO.permissions.toggle_switches_disabled(permission_id);
      }

      $.ajax({
        url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission_id+"",
        type: 'PUT',
        data: { permission }
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
  }
};

