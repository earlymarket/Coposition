class  Api::V1::Users::PermissionsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User

  before_action :require_ownership

  def index
    permissions = Permission.where(device_id: params[:device_id])
    render json: permissions
  end

  def update
    permission = Permission.find(params[:id])
    permission.update(allowed_params)
    render json: permission
  end

  def update_all
    permissions = Permission.where(device_id: params[:device_id])
    permissions.update_all(allowed_params)
    render json: permissions
  end

  private

  def allowed_params
    params.require(:permission).permit(:privilege, :bypass_fogging, :bypass_delay)
  end

  def require_ownership
    if params[:id]
      render status: 403, json: { message: 'You do not control that permission' } unless user_owns_permission?
    else
      params[:id] = params[:device_id]
      render status: 403, json: { message: 'You do not control that device' } unless user_owns_device?
    end
  end
end
