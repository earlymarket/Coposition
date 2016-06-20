class Users::PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_ownership, only: :update

  def index
    @device = Device.find(params[:device_id])
    @permissions = @device.permissions.includes(:permissible).order(:permissible_type, :id)
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
