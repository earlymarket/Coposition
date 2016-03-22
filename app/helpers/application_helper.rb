module ApplicationHelper

  def area_name(checkin)
    truncate(checkin.fogged_area || checkin.nearest_city.name)
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

  def avatar_for(resource, options = {})
    resource.avatar? ? cl_image_tag(resource.avatar.path, options) : cl_image_tag("placeholder_wzhvlw.png", options)
  end

end
