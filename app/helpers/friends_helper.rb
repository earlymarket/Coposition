module FriendsHelper

  def friends_name(friend)
    friend.username.present? ? friend.username : friend.email.split("@").first
  end

  def friends_last_checkin(checkins)
    if checkins.present?
      checkins = checkins.order(created_at: :desc)
      "<p>Last available reported area: #{checkins.first.fogged_area}</p>".html_safe
    else
      "<p>No location found</p>".html_safe
    end
  end
end
