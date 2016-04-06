window.COPO = window.COPO || {};
window.COPO.permissions = {
  check_disabled: function(){
    $('[data-switch=disallowed]').each(function(){
      if ($(this).children().children().prop('checked')){
        var permission_id =  $(this).data().permission;
        element = $("div[data-permission='"+ permission_id +"'].disable>label>input")
        element.prop("disabled", !element.prop("disabled"));
      }
    });
  },

  switch_change:function(){
    $(".switch").change(function( event ) {
      var permission_id = $(this).data().permission;
      var attribute = $(this).data().attribute;
      var switch_type = $(this).data().switch;

      var permission = $.grep(gon.permissions, function(perm){ return perm.id === permission_id; });
      var new_state = permission[0][attribute] = COPO.permissions.new_state(permission[0][attribute], switch_type);
      var device_id = permission[0]['device_id'];

      if (switch_type === "disallowed") {
        $("div[data-permission='"+permission_id+"'][data-switch=last_only]").find('input').prop("checked", false);
        element = $("div[data-permission='"+ permission_id +"'].disable>label>input")
        element.prop("disabled", !element.prop("disabled"));
      }

      var data = COPO.permissions.set_data(attribute, new_state);
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

