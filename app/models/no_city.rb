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

  def latitude
    nil
  end

  def longitude
    nil
  end

  def name
    'No nearby cities'
  end

  def country_code
    'No Country'
  end
end
