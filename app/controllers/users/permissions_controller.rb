class Users::PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_ownership, only: :update

  def index
    if params[:page] == 'devices'
      @device = Device.find(params[:device_id])
      @permissions = @device.permissions.includes(:permissible).order(:permissible_type, :id)
    elsif params[:page] == 'apps'
      device_ids = current_user.devices.select(:id)
      @permissible = Developer.find(params[:device_id])
      @permissions = Permission.where(device_id: device_ids, permissible_id: @permissible.id, permissible_type: 'Developer')
    elsif params[:page] == 'friends'
      device_ids = current_user.devices.select(:id)
      @permissible = User.find(params[:device_id])
      @permissions = Permission.where(device_id: device_ids, permissible_id: @permissible.id, permissible_type: 'User')
    end
    respond_to do |format|
      format.js
    end
  end

  def update
    if params[:page] == 'devices'
      @presenter = ::Users::DevicesPresenter.new(current_user, params, 'index')
      gon.push(@presenter.index_gon)
    elsif params[:page] == 'apps'
      approvals_presenter_and_gon('Developer')
    elsif params[:page] == 'friends'
      approvals_presenter_and_gon('User')
    end
    respond_to { |format| format.js }
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
