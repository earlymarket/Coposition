module ApplicationHelper

  def area_name(checkin)
    checkin.nearest_city.name unless Rails.env.test?
  end

end
