class Api::V1::Users::Devices::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :check_privilege

  def index
    checkins = @device.checkins.all
    checkins = checkins.map do |checkin|
      resolve checkin
    end

    render json: checkins.to_json
  end

  def last
    checkin = @device.checkins.last
    checkin = resolve checkin
    render json: checkin.to_json
  end

  def resolve checkin
    if params[:type] == "address"
        checkin.reverse_geocode!
        checkin.get_data
    else
      checkin.slice(:id, :uuid, :lat, :lng)
    end
  end

  def create
    checkin = Checkin.create(allowed_params)
    if checkin.id
      render json: checkin.to_json
    else
      render status: 400, json: { message: 'You must provide a UUID, lat and lng' }
    end
  end

  private

  def allowed_params
    params.require(:checkin).permit(:uuid, :lat, :lng)
  end

end