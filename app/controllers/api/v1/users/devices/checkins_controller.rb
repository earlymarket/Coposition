class Api::V1::Users::Devices::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :check_privilege

  def last
		checkin = @device.checkins.last
    if params[:type] == "address"
    	checkin.reverse_geocode!
      data = { uuid: checkin.uuid,
        address: nil,
        city: checkin.city,
        country: checkin.country
      }
      if checkin.device.fogged?
        data[:address] = "#{checkin.city}, #{checkin.country}"
      else
        data[:address] = checkin.address
      end
      render json: data
    else
    	render json: checkin.slice(:id, :uuid, :lat, :lng)
    end
  end

end