module ApplicationHelper

  def area_name(checkin)
    City.near(checkin).first[:name]
  end

end
