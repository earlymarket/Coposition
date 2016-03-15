module PermissionsHelper

  def permissible_title(permissible)
    if permissible.class.to_s == 'Developer'
      "<div class='valign-wrapper col s8'>
      #{h image_tag(permissible.logo.url(:thumb), alt: '', class: 'circle icon')}
      #{h permissible.company_name}
      </div>".html_safe
    else
      "<div class='valign-wrapper col s8'>#{h permissible.email}</div>".html_safe
    end
  end

end
