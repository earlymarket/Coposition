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

  def partial_class(thing)
    'master-switches' if thing.class != Permission
  end

  def switch_class(thing)
    thing.class == Permission ? 'permission-switch' : 'master'
  end

  def check_box_value(thing, type)
    if thing.class == Permission
      if ['disallowed', 'last_only'].include? type
        thing.privilege == type
      else
        thing[type]
      end
    end
  end

  def for_all(thing)
    'for all' if thing.class != Permission
  end

end
