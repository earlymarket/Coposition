module PermissionsHelper

  def permissible_title(permissible)
    if permissible.class.to_s == 'Developer'
      title = "<div class='valign-wrapper col s5'>
      #{image_tag(permissible.logo.url(:thumb), alt: '', class: 'circle icon')}
      #{permissible.company_name}
      </div>"
    else
      title = "<div class='valign-wrapper col s5'>#{permissible.email}</div>"
    end
    title.html_safe
  end
  
end