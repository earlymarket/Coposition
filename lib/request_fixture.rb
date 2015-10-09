class RequestFixture

  def initialize(uuid="356938035643809")
    @uuid = uuid
  end

  def w_gps
    # Including GPS data
    # Redbox version (temp disabled) no_gps + "165.48|13|0.03|E|12016.4438|N|2307.1256|A"
    no_gps + "165.48|13|0.03|E|-0.513069|N|51.588330|A"
  end

  def no_gps
    # Excluding GPS data
    @uuid + "|1314.21|490.01|260406|064951.000|"
  end

end