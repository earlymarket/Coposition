module ApplicationHelper

  def area_name(checkin)
    checkin.fogged_area || checkin.nearest_city.name
  end

  def fogged_icon(value)
    if value
      '<i class="material-icons">cloud_done</i>'.html_safe
    else
      '<i class="material-icons">cloud_off</i>'.html_safe
    end
  end

  def humanize_date(date)
    date.strftime("%a #{date.day.ordinalize} %b %T")
  end

end
