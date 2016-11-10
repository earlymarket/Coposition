module FriendsHelper
  def friends_device_last_checkin(checkins)
    if checkins.present?
      "<p>Last available reported area: #{checkins.first.fogged_city}</p>".html_safe
    else
      '<p>No location found</p>'.html_safe
    end
  end
end
