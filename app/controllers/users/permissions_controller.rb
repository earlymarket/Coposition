class Users::PermissionsController < ApplicationController

  before_action :authenticate_user!, :require_ownership

  def update
    permission = Permission.find(params[:id])
    permission.update(allowed_params)
    render nothing: true
  end

  private
    def allowed_params
      params.require(:permission).permit(:privilege, :bypass_fogging, :show_history)
    end

    def require_ownership
      unless user_owns_permission?
        flash[:alert] = "You do not control that permission"
        redirect_to root_path
      end
    end
end
