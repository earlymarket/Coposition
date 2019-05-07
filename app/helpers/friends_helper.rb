module FriendsHelper
  def friends_device_last_checkin(checkin)
    if checkin.present?
      "<p>Last available reported area: #{checkin['city']}</p>".html_safe
    else
      "<p>No location found</p>".html_safe
    end
  end
end
