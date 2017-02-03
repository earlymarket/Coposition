module DevicesHelper
  def devices_permitted_actors_for(device)
    device.developers + device.permitted_users
  end

  def devices_last_checkin(device)
    if device.checkins.exists?
      last_checkin = device.checkins.first
      postcode = last_checkin.postal_code
      last_checkin.address = last_checkin.address.gsub(' ' + postcode, '') if postcode
      "Last reported in #{last_checkin.address} on #{humanize_date_and_time(last_checkin.created_at)}
      <i data-device='#{device.id}' class='center-map material-icons'>my_location</i>".html_safe
    else
      'No Checkins found'.html_safe
    end
  end

  def devices_shared_link(device)
    return nil unless device.published?

    link = Rails.application.routes.url_helpers.shared_user_device_url(id: device.id, user_id: device.user_id)
    linkbox_id = "#linkbox#{device.id}"
    output = text_field_tag(nil, link, class: 'linkbox', id: linkbox_id)
    output << content_tag(:i, 'assignment', class: 'material-icons tooltipped clip_button',
                                            data: {
                                              'clipboard-target': linkbox_id,
                                              tooltip: 'Click to copy', position: 'right'
                                            })
    output
  end

  def devices_cloaked_info(value)
    if value
      "<div class='inline-text cloaked-info grey-text'>This device is cloaked. No friends or apps can see this device or its check-ins.</div>".html_safe 
    end
  end

  def devices_config_rows(config)
    return '<tr><td><i>No additional config</i></td></tr>'.html_safe unless config.custom.present?
    output = config.custom.map do |key, value|
      "<tr><td>#{key}</td><td>#{value}</td></tr>"
    end
    output.join.html_safe
  end

  def devices_label(presenter)
    label = ''
    user = (presenter.class == Users::FriendsPresenter) ? presenter.friend : presenter.user
    label << avatar_for(user, title: name_or_email_name(user), width: 40, height: 40)
    label << '&nbsp' + presenter.device.name
    label.html_safe
  end

  def devices_choose_icon(device, icon)
    link_to user_device_path(current_user.url_id, device.id, icon: icon), { method: :put, remote: true, class: 'valign-wrapper col s2', data: { icon: icon } } do
      if(device.icon == icon)
        "<i class='material-icons medium active'>#{icon}</i>".html_safe
      else
        "<i class='material-icons medium choose-icon'>#{icon}</i>".html_safe
      end
    end
  end
end
