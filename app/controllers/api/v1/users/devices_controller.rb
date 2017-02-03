class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:update, :create]

  before_action :check_user_approved_approvable, only: [:index, :show]
  before_action :check_user, only: [:update, :create]

  def index
    devices = req_from_coposition_app? ? @user.devices : @user.devices.public_info
    devices = devices.where(cloaked: false) unless current_user?(params[:user_id])
    render json: devices
  end

  def create
    result = ::Users::Devices::CreateDevice.new(@user, @dev, device_params)
    if result.save?
      device = result.device
      render json: { data: device, config: configuration(device) }
    else
      render status: 400, json: { error: result.error }
    end
  end

  def show
    device = @user.devices.where(id: params[:id]).first
    return unless device_exists? device && (!device.cloaked? || current_user?(params[:user_id]))
    device = device.public_info unless req_from_coposition_app? || @dev.configures_device?(device)
    render json: { data: device, config: configuration(device) }
  end

  def update
    device = @user.devices.where(id: params[:id]).first
    return unless device_exists? device
    device.update(device_params)
    if device.save
      render json: { data: device, config: configuration(device) }
    else
      render status: 400, json: { error: device.errors }
    end
  end

  private

  def check_user
    render status: 403, json: { error: 'User does not own device' } unless current_user?(params[:user_id])
  end

  def device_params
    params.require(:device).permit(:name, :uuid, :fogged, :delayed, :published, :cloaked, :alias)
  end

  def configuration(device)
    return unless device
    if req_from_coposition_app?
      device.config
    else
      @dev.configs.find_by(device_id: params[:id])
    end
  end
end
