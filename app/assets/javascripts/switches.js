window.Copo = window.Copo || {};
Copo.update_permission = function(permission, device_id, attribute, value){
  var data = switches_private.set_data(attribute, value);
  $.ajax({
    url: "/users/"+gon.current_user_id+"/devices/"+device_id+"/permissions/"+permission+"",
    type: 'PUT',
    data: { permission : data }
  });
}

Copo.disable_access_change = function(){
  $(".privilege").change(function( event ) {
    var state = switches_private.get_toggle_state(event.target);
    var permission = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var privilege = switches_private.set_privilege(state, "disallowed");
    switches_private.switch_last_only(permission);
    switches_private.disable_toggles(permission, state);
    Copo.update_permission(permission, device_id, 'privilege', privilege);
  });
}

Copo.last_checkin_change = function(){
  $(".last_only").change(function( event ) {
    var state = switches_private.get_toggle_state(event.target);
    var permission = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var privilege = switches_private.set_privilege(state, "last_only");
    Copo.update_permission(permission, device_id, 'privilege', privilege);
  });
}

Copo.bypass_change = function(){
  $(".bypass").change(function( event ) {
    var state = switches_private.get_toggle_state(event.target);
    var permission = switches_private.get_permission_id(event.target);
    var device_id = switches_private.get_device_id(event.target);
    var attribute = $(this).attr('name');
    Copo.update_permission(permission, device_id, attribute, state);
  });
}

Copo.check_disabled = function(){
  $(".privilege").each(function(){
    if ($(this).children().prop('checked')){
      var permission = switches_private.get_permission_id(this);
      switches_private.disable_toggles(permission, true);
    }
  });
}

var switches_private = {
  set_privilege: function(state, priv){
    if(state === true){ return priv }
    return "complete";
  },

  disable_toggles: function(permission, state){
    $("div[data-permission='"+ permission +"']>.disable>label>input").prop("disabled", state);
  },

  switch_last_only: function(permission){
    $("div[data-permission='"+ permission +"']>.last_only>label>input").prop("checked", false);
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
  }
};

