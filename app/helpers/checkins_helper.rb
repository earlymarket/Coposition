module CheckinsHelper

  def checkins_fogged_icon(value)
    if value
      value = '<i class="material-icons">cloud_done</i>'
    else
      value = '<i class="material-icons">cloud_off</i>'
    end
    value.html_safe
  end

  def checkins_humanize_date(date)
    date.strftime("%a #{date.day.ordinalize} %b %T")
  end

end
