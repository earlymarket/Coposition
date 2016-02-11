module ApplicationHelper

  def area_name(checkin)
    City.near(checkin).first[:name] unless Rails.env.test?
  end

end
