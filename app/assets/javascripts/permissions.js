window.Copo = window.Copo || {};
window.Copo.permissions = window.Copo.permissions || {};

Copo.permissions.disable_access_change = function(){
  $(".privilege").change(function( event ) {
    var permission_id = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var current_state = switches_private.get_attribute_state(permission_id, device_id, "privilege", "disallowed");
    var new_privilege = switches_private.new_privilege(current_state, "disallowed");
    switches_private.switch_last_only_off(permission_id);
    switches_private.disable_toggles(permission_id);
    switches_private.update_permission(permission_id, device_id, 'privilege', new_privilege);
  });
}

Copo.permissions.last_checkin_change = function(){
  $(".last_only").change(function( event ) {
    var permission_id = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var current_state = switches_private.get_attribute_state(permission_id, device_id, "privilege", "last_only");
    var new_privilege = switches_private.new_privilege(current_state, "last_only");
    switches_private.update_permission(permission_id, device_id, 'privilege', new_privilege);
  });
}

Copo.permissions.bypass_change = function(){
  $(".bypass").change(function( event ) {
    var permission_id = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var attribute = $(this).attr('name');
    var current_state = switches_private.get_attribute_state(permission_id, device_id, attribute);
    var new_state = !current_state
    switches_private.update_permission(permission_id, device_id, attribute, new_state);
  });
}

Copo.permissions.check_disabled = function(){
  $(".privilege").each(function(){
    if ($(this).children().prop('checked')){
      var permission_id = switches_private.get_permission_id(this);
      switches_private.disable_toggles(permission_id, true);
    }
  });
}

var switches_private = {
  update_permission: function(permission_id, device_id, attribute, value){
    var data = switches_private.set_data(attribute, value);
    $.ajax({
      url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission_id+"",
      type: 'PUT',
      data: { permission : data }
    });
  },

  new_privilege: function(current_state, button){
    if(current_state === "disallowed"){
      return "complete"
    } else if(button === "disallowed"){
      return "disallowed"
    } else if(current_state === "complete"){
      return "last_only"
    } else {
      return "complete"
    }
  },

  disable_toggles: function(permission_id){
    element = $("div[data-permission='"+ permission_id +"']>.disable>label>input")
    element.prop("disabled", !element.prop("disabled"));
  },

  switch_last_only_off: function(permission_id){
    $("div[data-permission='"+ permission_id +"']>div>.last_only>input").prop("checked", false);
  },

  get_permission_id: function(element){
    return $(element).parents('div.col').data().permission;
  },

  get_device_id: function(element){
    return $(element).parents('ul.collection').data().device;
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

  get_attribute_state: function(permission_id, device_id, attribute, button){
    var current_state = null;
    gon.permissions.forEach(function(perm){
      if (perm.id === permission_id){
        current_state = perm[attribute];
        perm[attribute] = switches_private.reassign_permission(perm[attribute], attribute, button);
      }
    });
    return current_state;
  },

  reassign_permission: function(state, attribute, button){
    if(attribute === 'privilege'){
      return switches_private.new_privilege(state, button);
    } else {
      return !state;
    }
  }
};

