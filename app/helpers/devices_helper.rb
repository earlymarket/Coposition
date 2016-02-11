module DevicesHelper
  def devices_last_checkin(device)
    if device.checkins.exists?
      message = "<p>Last reported in #{device.checkins.last.address}</p>"
    else
      message = "<p>No Checkins found</p>"
    end
    message.html_safe
  end

  def devices_fog_status(device)
    if device.fogged
      message = "<p>Fogging is enabled on this device.</p>"
      message.html_safe
    end
  end

  def devices_delay_status(device)
    if device.delayed
      message = "<p>Timeshifted with a delay of #{device.delayed} minutes</p>"
      message.html_safe
    end
  end
end

