module DevicesHelper
  def devices_last_checkin(device)
    if device.checkins.exists?
      message = "<p class='list-group-item-text'>Last reported in #{device.checkins.last.address}</p>"
    else
      message = "<p class='list-group-item-text'>No Checkins found</p>"
    end
    message.html_safe
  end

  def devices_fog_status(device)
    if device.fogged
      message = "<p class='list-group-item-text'>Fogging is enabled on this device.</p>"
      message.html_safe
    end
  end

  def devices_delay_status(device)
    if device.delayed
      message = "<p class='list-group-item-text'>Timeshifted with a delay of #{device.delayed.to_s} minutes</p>"
      message.html_safe
    end
  end
end

