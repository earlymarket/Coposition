class RequestFixture

  def initialize(imei="356938035643809")
    @imei = imei
  end

  def w_gps
    # Including GPS data
    no_gps + "165.48|13|0.03|E|12016.4438|N|2307.1256|A"
  end

  def no_gps
    # Excluding GPS data
    @imei + "|1314.21|490.01|260406|064951.000|"
  end

end