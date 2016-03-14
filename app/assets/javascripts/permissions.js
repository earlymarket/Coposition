window.Copo = window.Copo || {};
window.Copo.permissions = window.Copo.permissions || {};

Copo.permissions.update_permission = function(permission, device_id, attribute, value){
  var data = switches_private.set_data(attribute, value);
  $.ajax({
    url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission+"",
    type: 'PUT',
    data: { permission : data }
  });
}

Copo.permissions.disable_access_change = function(){
  $(".privilege").change(function( event ) {
    var permission = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var current_state = switches_private.get_permission_state(permission, device_id, "privilege", "disallowed");
    var new_privilege = switches_private.new_privilege(state, "disallowed");
    switches_private.switch_last_only(permission);
    switches_private.disable_toggles(permission, state);
    Copo.permissions.update_permission(permission, device_id, 'privilege', new_privilege);
  });
}

Copo.permissions.last_checkin_change = function(){
  $(".last_only").change(function( event ) {
    var permission = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var current_state = switches_private.get_permission_state(permission, device_id, "privilege", "last_only");
    var new_privilege = switches_private.new_privilege(state, "last_only");
    Copo.permissions.update_permission(permission, device_id, 'privilege', new_privilege);
  });
}

Copo.permissions.bypass_change = function(){
  $(".bypass").change(function( event ) {
    var permission = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var attribute = $(this).attr('name');
    var current_state = switches_private.get_permission_state(permission, device_id, attribute);
    var new_state = !current_state
    Copo.permissions.update_permission(permission, device_id, attribute, new_state);
  });
}

Copo.permissions.check_disabled = function(){
  $(".privilege").each(function(){
    if ($(this).children().prop('checked')){
      var permission = switches_private.get_permission_id(this);
      switches_private.disable_toggles(permission, true);
    }
  });
}

var switches_private = {
  new_privilege: function(state, priv){
    if(state === "disallowed"){ return "complete" }
    if(priv === "disallowed"){ return "disallowed" }
    if(state === "complete"){ return "last_only"}
    return "complete";
  },

  disable_toggles: function(permission, state){
    element = $("div[data-permission='"+ permission +"']>.disable>label>input")
    element.prop("disabled", !element.prop("disabled"));
  },

  switch_last_only: function(permission){
    $("div[data-permission='"+ permission +"']>div>.last_only>input").prop("checked", false);
  },

  get_permission_id: function(element){
    return $(element).parents('div.col').data().permission;
  },

  get_device_id: function(element){
    return $(element).parents('ul.collection').data().device;
  },

  get_toggle_state: function(element){
    return $(element).prop('checked');
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

  get_permission_state: function(permission, device_id, attribute, button){
    var current_state = null;
    gon.permissions.forEach(function(perm){
      if (perm.id === permission){
        current_state = perm[attribute];
        if(attribute === 'privilege'){
          perm[attribute] = switches_private.new_privilege(current_state, button);
        } else {
          perm[attribute] = !current_state;
        }
      }
    });
    return current_state;
  }
};

