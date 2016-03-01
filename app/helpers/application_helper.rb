module ApplicationHelper

  def area_name(checkin)
    truncate(checkin.nearest_city.name)
  end

  def fogged_icon(value)
    if value
      value = '<i class="material-icons">cloud_done</i>'
    else
      value = '<i class="material-icons">cloud_off</i>'
    end
    value.html_safe
  end

end
