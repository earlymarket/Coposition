module PermissionsHelper

  def permissions_fogging_checkbox(permission)
    if permission.bypass_fogging == true 
      box = '<input type="checkbox" checked>'
    else
      box = '<input type="checkbox">'
    end
    box.html_safe
  end

  def permissions_history_checkbox(permission)
    if permission.show_history == true 
      box = '<input type="checkbox" checked>'
    else
      box = '<input type="checkbox">'
    end
    box.html_safe
  end

  def permissions_privilege_options(permission)
    if permission.privilege == 'complete'
      options = 
      '<option selected="selected" value="complete">Complete</option>
      <option value="last_only">Last Checkin Only</option>
      <option value="disallowed">Disallowed</option>'
    elsif permission.privilege == 'last_only'
     options = 
      '<option value="complete">Complete</option>
      <option selected="selected" value="last_only">Last Checkin Only</option>
      <option value="disallowed">Disallowed</option>'
    else
      options = 
      '<option value="complete">Complete</option>
      <option value="last_only">Last Checkin Only</option>
      <option selected="selected" value="disallowed">Disallowed</option>'
    end
    options.html_safe
  end

end