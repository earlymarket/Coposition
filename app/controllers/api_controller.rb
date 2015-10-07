class ApiController < ApplicationController
	protect_from_forgery with: :null_session

  def index
    @w_gps = RequestFixture.new.w_gps
    @mapping = Checkin.string_order
    @w_gps_response = JSON.pretty_generate(Checkin.first.as_json)
  end

end
