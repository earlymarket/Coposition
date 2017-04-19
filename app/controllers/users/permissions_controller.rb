class Users::PermissionsController < ApplicationController
  protect_from_forgery except: :index
  before_action :authenticate_user!
  before_action :require_ownership, only: :update

  def index
    @permissions_presenter = ::Users::PermissionsPresenter.new(current_user, params, "index")
    respond_to { |format| format.js }
  end

  def update
    @permissions_presenter = ::Users::PermissionsPresenter.new(current_user, params, "update")
    @permissions_presenter.permission.update(allowed_params)
    gon.push(@permissions_presenter.gon(params[:from]))
    respond_to { |format| format.js }
  end

  private

  def allowed_params
    params.require(:permission).permit(:privilege, :bypass_fogging, :bypass_delay)
  end

  def require_ownership
    return if user_owns_permission?
    flash[:alert] = "You do not control that permission"
    redirect_to root_path
  end
end
