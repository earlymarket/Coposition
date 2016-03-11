var switches = {
  update_permission: function(current_user_id, permission, device_id, attribute, value){
    var data = set_data(attribute, value);
    $.ajax({
      url: "/users/"+current_user_id+"/devices/"+device_id+"/permissions/"+permission+"",
      type: 'PUT',
      data: { permission : data }
    });
  }

  disable_access_change: function(current_user_id){
    $(".privilege").change(function( event ) {
      var state = get_toggle_state(event.target);
      var permission = get_permission_id(event.target);
      var device_id = get_device_id(event.target);
      var privilege = set_privilege(state, "disallowed")
      switch_last_only(permission);
      disable_toggles(permission, state);
      update_permission(current_user_id, permission, device_id, 'privilege', privilege)
    });
  }

  last_checkin_change: function(current_user_id){
    $(".last_only").change(function( event ) {
      var state = get_toggle_state(event.target);
      var permission = get_permission_id(event.target);
      var device_id = get_device_id(event.target);
      var privilege = set_privilege(state, "last_only")
      update_permission(current_user_id, permission, device_id, 'privilege', privilege)
    });
  }

  bypass_change: function(current_user_id){
    $(".bypass").change(function( event ) {
      var state = get_toggle_state(event.target);
      var permission = get_permission_id(event.target);
      var device_id = get_device_id(event.target);
      var attribute = $(this).attr('name');
      update_permission(current_user_id, permission, device_id, attribute, state)
    });
  }

  function set_privilege(state, priv){
    if(state == true){ return priv };
    return "complete"
  }

  function disable_toggles(permission, state){
    $("div[data-permission='"+ permission +"']>.disable>label>input").prop("disabled", state)
  }

  function switch_last_only(permission){
    $("div[data-permission='"+ permission +"']>.last_only>label>input").prop("checked", false)
  }

  function get_permission_id(element){
    return $(element).parents('div.col').data().permission;
  }

  function get_device_id(element){
    return $(element).parents('ul.collection').data().device;
  }

  function get_toggle_state(element){
    return $(element).prop('checked');
  }

  function set_data(attribute, value){
    if (attribute == 'privilege'){
      return { privilege: value }
    } else if (attribute == 'bypass_fogging'){
      return { bypass_fogging: value }
    } else {
      return { bypass_delay: value }
    }
  }
}
