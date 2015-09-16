class ApiController < ApplicationController

  def index
    @w_gps = RequestFixture.w_gps
    @mapping = Checkin.string_order
    @w_gps_response = JSON.pretty_generate(Checkin.first.as_json)
  end

end
