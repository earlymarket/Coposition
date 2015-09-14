class ApiController < ApplicationController

  def index
    @w_gps = RequestFixture.w_gps
    @mapping = Checkin.string_order
  end

end
