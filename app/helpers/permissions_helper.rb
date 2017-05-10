module PermissionsHelper
  include ApprovalsHelper
  def permissions_permissible_title(permissible)
    title = '<div class="valign-wrapper">'
    title += avatar_for(permissible)
    title += '<p class="permissible-name">'
    title += approvals_approvable_name(permissible)
    title += '</p></div>'
    title.html_safe
  end

  def permissions_device_title(device)
    title = '<div class="valign-wrapper"><i class="material-icons small">'
    title += device.icon + '</i>'
    title += '<p class="permissible-name">'
    title += device.name + '</p></div>'
    title.html_safe
  end

  def permissions_switch_class(control_object)
    control_object.class == Permission ? "permission-switch" : "master"
  end

  def permissions_label_id(control_object, switchtype)
    if control_object.class == Permission
      "#{switchtype}-#{control_object.id}"
    else
      "master-#{switchtype}-#{control_object.id}"
    end
  end

  def permissions_check_box_value(control_object, type)
    return unless control_object.class == Permission
    if %w(disallowed last_only complete).include? type
      control_object.privilege == type
    else
      control_object[type]
    end
  end
end
