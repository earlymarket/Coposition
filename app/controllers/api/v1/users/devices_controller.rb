class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  def index
    list = []
    @user.devices.except(:fogged).map do |devc|
      if devc.privilege_for(@dev) == "complete"
        list << devc.device_checkin_hash
      end
    end
    respond_with list
  end

  def show
    list = []
    @user.devices.where(id: params[:id]).except(:fogged).map do |devc|
      if devc.privilege_for(@dev) == "complete"
        list << devc.device_checkin_hash
      else
        return head status: :unauthorized
      end
    end
    respond_with list
  end

  def update
    if device = Device.find(params[:id])
      device.update(device_params)
      render json: device
    else
      render status: 400, json: { message: 'Device does not exist' }
    end
  end

  private

    def device_params
      params.require(:device).permit(:name, :fogged, :delayed)
    end

end
