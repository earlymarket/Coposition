class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:update, :create]

  before_action :check_user_approved_approvable, only: [:index, :show]
  before_action :check_user, only: [:update, :create]

  def index
    devices = req_from_coposition_app? ? @user.devices : @user.devices.public_info
    render json: devices
  end

  def create
    result = ::Users::Devices::CreateDevice.new(@user, @dev, device_params)
    if result.save?
      device = result.device
      render json: device
    else
      render status: 400, json: { message: result.error }
    end
  end

  def show
    device = @user.devices.where(id: params[:id])
    device = device.public_info unless req_from_coposition_app? || @dev.owns_device?(device)
    render json: device
  end

  def update
    device = @user.devices.where(id: params[:id]).first
    return unless device_exists? device
    device.update(device_params)
    render json: device
  end

  private

  def check_user
    render status: 403, json: { message: 'User does not own device' } unless current_user?(params[:user_id])
  end

  def device_params
    params.require(:device).permit(:name, :uuid, :fogged, :delayed, :alias)
  end
end
