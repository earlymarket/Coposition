module DevicesHelper
  def devices_last_checkin(device)
    if device.past_checkins.exists?
      last_checkin = device.past_checkins.first
      postcode = last_checkin.postal_code
      last_checkin.address = last_checkin.address.gsub(" " + postcode, "") if postcode
      "Last reported in #{last_checkin.address} on #{humanize_date_and_time(last_checkin.created_at)}
      <i data-device='#{device.id}' class='center-map material-icons'>my_location</i>".html_safe
    else
      "No Checkins found"
    end
  end

  def devices_shared_link(device)
    return nil unless device.published?

    link = Rails.application.routes.url_helpers.shared_user_device_url(id: device.id, user_id: device.user_id)
    output = text_field_tag(nil, link, class: "linkbox truncate", id: "linkbox#{device.id}")
    output << content_tag(:i, "assignment", class: "material-icons tooltipped clip_button",
                                            data: {
                                              "clipboard-target": "#linkbox#{device.id}",
                                              tooltip: "Click to copy", position: "right"
                                            })
    output
  end

  def devices_cloaked_info(value)
    return unless value
    "<div class='inline-text cloaked-info grey-text'>This device is cloaked. No friends or apps can see this device or its check-ins.</div>".html_safe
  end

  def devices_choose_icon(device, icon)
    link_to Rails.application.routes.url_helpers
      .user_device_path(current_user.url_id, device.id, device: { icon: icon }),
      class: "col s2", method: :put, remote: true, data: { icon: icon } do
      if device.icon == icon
        "<i class='material-icons medium active'>#{icon}</i>#{icon_label(icon)}".html_safe
      else
        "<i class='material-icons medium choose-icon'>#{icon}</i>#{icon_label(icon)}".html_safe
      end
    end
  end

  private

  def icon_label(icon)
    if icon == "desktop_windows"
      "<p class='icon-label'>desktop</p>"
    elsif icon == "devices_other"
      "<p class='icon-label'>other</p>"
    else
      "<p class='icon-label'>#{icon}</p>"
    end
  end
end
