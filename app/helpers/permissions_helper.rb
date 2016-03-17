module PermissionsHelper

  def permissible_title(permissible)
    if permissible.class.to_s == 'Developer'
      "#{avatar_for(permissible, { size: '60x60', crop: :thumb, gravity: :face, radius: :max })}
      #{h permissible.company_name}".html_safe
    else
      "#{avatar_for(permissible, { size: '60x60', crop: :thumb, gravity: :face, radius: :max })}
      #{h permissible.email}".html_safe
    end
  end

end
