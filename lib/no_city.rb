class NoCity
  attr_reader :lat
  attr_reader :lng
  def initialize(lat, lng)
    @lat = lat
    @lng = lng
  end

  def nil?
    true
  end

  def id
    nil
  end

  def latitude
    lat + rand(-0.5..0.5)
  end

  def longitude
    lng + rand(-0.5..0.5)
  end

  def name
    'No nearby cities'
  end

  def country_code
    'No Country'
  end
end
