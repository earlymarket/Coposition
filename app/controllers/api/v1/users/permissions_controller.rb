class  Api::V1::Users::PermissionsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User

  before_action :require_ownership

  def update
    permission = Permission.find(params[:id])
    permission.update(allowed_params)
    render json: permission
  end

  def update_all
    device = Device.find(params[:device_id])
    permissions = device.permissions
    permissions.update_all(allowed_params)
    render json: permissions
  end

  private
    def allowed_params
      params.require(:permission).permit(:privilege, :bypass_fogging, :show_history)
    end

    def require_ownership
      if params[:id]
        render status: 403, json: { message: "You do not control that permission" } unless user_owns_permission?
      else
        params[:id] = params[:device_id]
        render status: 403, json: { message: "You do not control that device" } unless user_owns_device?
      end
    end
end
