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

  def checkins_fogged_address(checkin)
    "<li>Fogged Address: #{checkin.get_data.address}</li>".html_safe if checkin.fogged
  end

  def checkins_static_map_url(checkin)
    checkin = Checkin.find(checkin.id)
    fogged = Checkin.find(checkin.id).get_data
    map_url = "http://maps.googleapis.com/maps/api/staticmap?size=500x250&markers=|'+'#{checkin.lat},#{checkin.lng}'+'|"
    map_url.concat("'+'&markers=|icon:http://www.trenatics.com/public/images/iconfile/file/ic_cloud_done_black_18dp.png|'+'#{fogged.lat},#{fogged.lng}'+'|") if fogged
    map_url.html_safe
  end

end
