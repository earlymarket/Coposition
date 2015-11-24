class Api::V1::Users::Devices::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :check_privilege

  def last
		checkin = @device.checkins.last
    if params[:type] == "address"
    	checkin.reverse_geocode!
      render json: checkin.get_data
    else
    	render json: checkin.slice(:id, :uuid, :lat, :lng)
    end
  end

end