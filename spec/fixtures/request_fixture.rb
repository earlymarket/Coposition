class RequestFixture

  class << self

    def w_gps
      # Including GPS data
      "A|2307.1256|N|12016.4438|E|0.03|13|165.48|" + no_gps
    end

    def no_gps
      # Excluding GPS data
      "064951.000|260406|490.01|1314.21|356938035643809"
    end

  end
end