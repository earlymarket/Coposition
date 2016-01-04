class Api::V1::Users::Devices::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :check_privilege

  def index
    checkins = @device.checkins.all
    checkins = checkins.map do |checkin|
      if params[:type] == "address"
        checkin.reverse_geocode!
        checkin = checkin.get_data
      else
        checkin = checkin.slice(:id, :uuid, :lat, :lng)
      end
    end

    render json: checkins.to_json
  end

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