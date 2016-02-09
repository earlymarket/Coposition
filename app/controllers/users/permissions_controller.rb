class Users::PermissionsController < ApplicationController

  def index
    devices = current_user.devices
    @permissions = []
    devices.each do |device|
      device.permissions.each do |permission|
        @permissions << permission
      end
    end
    render json: @permissions
  end

  def update
    @permission = Permission.find(params[:id])
    @permission.update(allowed_params)
    render nothing: true
  end

  def update_for_device
    device = Device.find(params[:device_id])
    @permissions = device.permissions
    @permissions.each do |permission|
      permission.update(allowed_params)
    end
    render nothing: true
  end

  def update_for_permissible
    model = model_find(params[:permissible_type])
    permissible = model.find(params[:permissible_id])
    @permissions = current_user.permissions.where(permissible: permissible)
    @permissions.each do |permission|
      permission.update(allowed_params)
    end
    render nothing: true
  end

  private
    def allowed_params
      params.require(:permission).permit(:privilege, :bypass_fogging, :show_history)
    end
end
