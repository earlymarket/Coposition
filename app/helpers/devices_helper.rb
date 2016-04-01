module DevicesHelper

  def devices_permitted_actors_for(device)
    device.developers + device.permitted_users
  end

  def devices_last_checkin(device)
    if device.checkins.exists?
      checkins = device.checkins.order(created_at: :desc)
      "<p>Last reported in #{checkins.first.address}</p>".html_safe
    else
      "<p>No Checkins found</p>".html_safe
    end
  end

  def devices_delay_icon(value)
    if value
      '<i class="material-icons">hourglass_full</i>'.html_safe
    else
      '<i class="material-icons">hourglass_empty</i>'.html_safe
    end
  end

  def devices_published_icon(device)
    if device.published?
      '<i class="material-icons">visibility</i>'.html_safe
    else
      '<i class="material-icons">visibility_off</i>'.html_safe
    end
  end

  def devices_shared_link(device)
    link_to('Link to your last location', shared_user_device_path(id: device.id, user_id: params['user_id'] || device.user_id)) if device.published?
  end
end
