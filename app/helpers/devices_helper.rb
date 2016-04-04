module DevicesHelper

  def devices_permitted_actors_for(device)
    device.developers + device.permitted_users
  end

  def devices_last_checkin(device)
    if device.checkins.exists?
      checkins = device.checkins.order('created_at DESC')
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

  def devices_shared_icon(device)
    if device.published?
      '<i class="material-icons">visibility</i>'.html_safe
    else
      '<i class="material-icons">visibility_off</i>'.html_safe
    end
  end

  def devices_shared_link(device)
    return nil unless device.published?
    link = shared_user_device_url(id: device.id, user_id: params['user_id'] || device.user_id)
    output = text_field_tag(nil, link,
    { class: 'linkbox',
      id: 'linkbox'<< device.id.to_s
    })

    output << content_tag(:i, 'assignment',
      { class: 'material-icons tooltipped clip_button',
        data:
        {'clipboard-target': ('linkbox' << device.id.to_s),
         tooltip: 'Click to copy',
         position: 'right'
        }
      })
    output
  end

end
