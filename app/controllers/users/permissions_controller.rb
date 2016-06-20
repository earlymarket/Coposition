class Users::PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_ownership, only: :update

  def index
    if params[:from] == 'devices'
      @device = Device.find(params[:device_id])
      @permissions = @device.permissions.includes(:permissible).order(:permissible_type, :id)
    elsif params[:from] == 'apps'
      device_ids = current_user.devices.select(:id)
      @permissible = Developer.find(params[:device_id])
      @permissions = Permission.where(device_id: device_ids, permissible_id: @permissible.id, permissible_type: 'Developer')
    else
      device_ids = current_user.devices.select(:id)
      @permissible = User.find(params[:device_id])
      @permissions = Permission.where(device_id: device_ids, permissible_id: @permissible.id, permissible_type: 'User')
    end
    respond_to do |format|
      format.js
    end
  end

  def update
    presenter = ::Users::PermissionsPresenter.new(current_user, params)
    presenter.permission.update(allowed_params)
    gon.push(presenter.gon)
    respond_to do |format|
      format.js
    end
  end

  private

  def allowed_params
    params.require(:permission).permit(:privilege, :bypass_fogging, :bypass_delay)
  end

  def require_ownership
    return if user_owns_permission?
    flash[:alert] = 'You do not control that permission'
    redirect_to root_path
  end
end
