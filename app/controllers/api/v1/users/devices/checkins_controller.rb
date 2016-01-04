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
    binding.pry
    if params[:type] == "address"
        checkin.reverse_geocode!
        checkin.get_data
    else
      checkin.slice(:id, :uuid, :lat, :lng)
    end
  end

end