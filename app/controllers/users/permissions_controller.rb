class Users::PermissionsController < ApplicationController
  before_action :authenticate_user!, :require_ownership

  def update
    @permission = Permission.find(params[:id])
    @permission.update(allowed_params)
    devices = current_user.devices.order(:id).includes(:permissions)
    if current_user.checkins.exists?
      gon.checkins = current_user.checkins.calendar_data
    end
    gon.permissions = devices.map(&:permissions).inject(:+)
    gon.current_user_id = current_user.id
    gon.devices = devices
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
