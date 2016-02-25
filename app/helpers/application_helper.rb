module ApplicationHelper

  def area_name(checkin)
    checkin.nearest_city.name
  end

end
