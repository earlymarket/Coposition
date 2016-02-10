class Users::PermissionsController < ApplicationController

  def update
    @permission = Permission.find(params[:id])
    @permission.update(allowed_params)
    render nothing: true
  end

  private
    def allowed_params
      params.require(:permission).permit(:privilege, :bypass_fogging, :show_history)
    end
end
