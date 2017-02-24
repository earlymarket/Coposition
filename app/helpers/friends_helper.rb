module FriendsHelper
  def friends_device_last_checkin(checkin)
    if checkin.present?
      "<p>Last available reported area: #{checkin['city']}</p>".html_safe
    else
      '<p>No location found</p>'.html_safe
    end
  end

  def friends_device_range_filter(text, from)
    link_to(text, show_device_user_friend_path(current_user.url_id, @presenter.friend,
                                               device_id: @presenter.device, from: from, to: Date.today), method: :get)
  end
end
