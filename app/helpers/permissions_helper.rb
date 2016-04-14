module PermissionsHelper

  def permissible_title(permissible)
    title_start = "<div class=\"valign-wrapper\">#{avatar_for(permissible)}"
    title_end = '</div>'
    if permissible.class.to_s == 'Developer'
      title = title_start + "#{h permissible.company_name}" + title_end
    else
      title = title_start + "#{h permissible.email}" + title_end
    end
    title.html_safe
  end

  def permissions_control_class(permissionable)
    'master-switches' if permissionable.class != Permission
  end

  def permissions_switch_class(permissionable)
    permissionable.class == Permission ? 'permission-switch' : 'master'
  end

  def permissions_check_box_value(permissionable, type)
    if permissionable.class == Permission
      if ['disallowed', 'last_only'].include? type
        permissionable.privilege == type
      else
        permissionable[type]
      end
    end
  end

  def permissions_for_all(permissionable)
    'for all' if permissionable.class != Permission
  end

end
