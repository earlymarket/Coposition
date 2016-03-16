window.COPO = window.COPO || {};
window.COPO.permissions = {
  check_disabled: function(){
    $('[name=disallowed]').each(function(){
      if ($(this).children().prop('checked')){
        var permission_id = $(this).parents('div.permission').data().permission;
        element = $("div[data-permission='"+ permission_id +"']>.disable>label>input")
        element.prop("disabled", !element.prop("disabled"));
      }
    });
  },

  switch_change:function(){
    $(".switch").change(function( event ) {
      var permission_id = $(event.target).parents('div.permission').data().permission;
      var device_id = null;
      gon.permissions.forEach(function(perm){
        if (perm.id === permission_id){ device_id = perm.device_id; }
      });
      var attribute = $(this).children().attr('class');
      var button = $(this).children().attr('name');
      var current_state = COPO.permissions.get_attribute_state(permission_id, attribute, button);
      var new_state = COPO.permissions.new_state(current_state, button);
      if (button === "disallowed") {
        $("div[data-permission='"+ permission_id +"']>.disable>.privilege>input").prop("checked", false);
        element = $("div[data-permission='"+ permission_id +"']>.disable>label>input")
        element.prop("disabled", !element.prop("disabled"));
      }
      COPO.permissions.update_permission(permission_id, device_id, attribute, new_state);
    })
  },

  update_permission: function(permission_id, device_id, attribute, value){
    var data = COPO.permissions.set_data(attribute, value);
    $.ajax({
      url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission_id+"",
      type: 'PUT',
      data: { permission : data }
    });
  },

  new_state: function(current_state, button){
    if(current_state === "disallowed"){
      return "complete"
    } else if(button === "disallowed"){
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
  },

  get_attribute_state: function(permission_id, attribute, button){
    var current_state = null;
    gon.permissions.forEach(function(perm){
      if (perm.id === permission_id){
        current_state = perm[attribute];
        perm[attribute] = COPO.permissions.reassign_permission(perm[attribute], attribute, button);
      }
    });
    return current_state;
  },

  reassign_permission: function(state, attribute, button){
    if(attribute === 'privilege'){
      return COPO.permissions.new_state(state, button);
    } else {
      return !state;
    }
  }
};
