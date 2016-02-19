class  Api::V1::Users::PermissionsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User

  before_action :require_ownership

  def update
    permission = Permission.where(id: params[:id], device_id: params[:device_id]).first
    if permission_exists? permission
      permission.update(allowed_params)
      render json: permission
    end
  end

  def update_all
    permissions = Permission.where(device_id: params[:device_id])
    permissions.update_all(allowed_params)
    render json: permissions
  end

  private
    def allowed_params
      params.require(:permission).permit(:privilege, :bypass_fogging, :show_history)
    end

    def require_ownership
      params[:id] = params[:device_id]
      render status: 403, json: { message: "You do not control that device" } unless user_owns_device?
    end
end
