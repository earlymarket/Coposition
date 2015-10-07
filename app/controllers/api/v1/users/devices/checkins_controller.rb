class Api::V1::Users::Devices::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device

  def last
  	respond_with @device.checkins.select(:uuid, :lat, :lng).last
  end	

end