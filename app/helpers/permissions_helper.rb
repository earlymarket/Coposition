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

end
