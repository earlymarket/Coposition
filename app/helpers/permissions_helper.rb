module PermissionsHelper

  def permissible_title(permissible)
    if permissible.class.to_s == 'Developer'
      "<div class='valign-wrapper col s8'>
      #{if permissible.avatar?  then cl_image_tag(permissible.avatar.path, { size: '60x60', crop: :thumb, gravity: :face, radius: :max }) end}
      #{h permissible.company_name}
      </div>".html_safe
    else
      "<div class='valign-wrapper col s8'>#{h permissible.email}</div>".html_safe
    end
  end

end
