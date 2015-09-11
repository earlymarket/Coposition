class RequestFixture

  class << self

    def w_gps
      # Including GPS data
      no_gps + "165.48|13|0.03|E|12016.4438|N|2307.1256|A"
    end

    def no_gps
      # Excluding GPS data
      "356938035643809|1314.21|490.01|260406|064951.000|"
    end

  end
end