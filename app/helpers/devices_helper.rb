module DevicesHelper
  def devices_last_checkin(device)
    if device.checkins.exists?
      message = "<p>Last reported in #{device.checkins.last.address}</p>"
    else
      message = "<p>No Checkins found</p>"
    end
    message.html_safe
  end

  def devices_fog_message(device)
    if device.fogged
      "#{device.name} has been fogged"
    else
      "#{device.name} is no longer fogged"
    end
  end

  def devices_delay_message(device)
    if device.delayed
      "#{device.name} is now timeshifted by #{device.delayed} minutes"
    else
      "#{device.name} is not timeshifted"
    end
  end

  def fog_button_text(device)
    if device.fogged?
      "Currently Fogged"
    else
      "Fog"
    end
  end
end
