module DevicesHelper
  def devices_last_checkin(device)
    if device.checkins.exists?
      message = "<p>Last reported in #{device.checkins.last.address}</p>"
    else
      message = "<p>No Checkins found</p>"
    end
    message.html_safe
  end

  def devices_fog_button_text(device)
    if device.fogged?
      "Fogging is on"
    else
      "Fogging is off"
    end
  end
end
