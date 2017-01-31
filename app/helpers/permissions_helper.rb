module PermissionsHelper
  include ApprovalsHelper
  def permissible_title(permissible)
    title_start = "<div class=\"valign-wrapper\">#{avatar_for(permissible)}"
    title_end = '</div>'
    title = title_start + "<p class=\"permissible-name\">#{approvals_approvable_name(permissible)}</p>" + title_end
    title.html_safe
  end

  def permissions_control_class(permissionable)
    if permissionable.class != Permission
      " master-switches permissionable-id-#{permissionable.id}"
    else
      " normal-switches permissionable-id-#{permissionable.id}"
    end
  end

  def permissions_switch_class(permissionable)
    permissionable.class == Permission ? 'permission-switch' : 'master'
  end

  def permissions_label_id(permissionable, switchtype)
    if permissionable.class == Permission
      "#{permissionable.id}_#{switchtype}"
    else
      "master_#{permissionable.id}_#{switchtype}"
    end
  end

  def permissions_check_box_value(permissionable, type)
    if permissionable.class == Permission
      if %w(disallowed last_only complete).include? type
        permissionable.privilege == type
      else
        permissionable[type]
      end
    end
  end
end
