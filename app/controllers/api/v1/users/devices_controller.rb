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
    device = Device.new
    device = Device.find_by uuid: device_params[:uuid] if device_params[:uuid].present?
    if device
      if device.user.nil?
        device.construct(@user, device_params[:name])
        render json: device
      else
        render status: 400, json: { message: 'This device has already been assigned to a user' }
      end
    else
      render status: 400, json: { message: 'The UUID provided does not match an existing device' }
    end
  end

  def show
    device = @user.devices.where(id: params[:id])
    device = device.public_info unless req_from_coposition_app?
    render json: device
  end

  def update
    device = @user.devices.where(id: params[:id]).first
    if device_exists? device
      device.update(device_params)
      render json: device
    end
  end

  private

    def check_user
      unless current_user?(params[:user_id])
        render status: 403, json: { message: 'User does not own device' }
      end
    end

    def device_params
      params.require(:device).permit(:name, :uuid, :fogged, :delayed, :alias)
    end

end

