class Api::V1::Users::PermissionsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User

  before_action :require_ownership

  def index
    device = Device.find(params[:device_id])
    permissions = params[:complete] ? device.complete_permissions : device.permissions
    render json: permissions.not_coposition_developers
  end

  def update
    permission = Permission.find(params[:id])
    permission.update(allowed_params)
    CreateActivity.call(entity: permission, action: :update, owner: current_user, params: allowed_params.to_h)
    render json: permission
  end

  def update_all
    permissions = Permission.where(device_id: params[:device_id]).not_coposition_developers
    permissions.each do |permission|
      CreateActivity.call(entity: permission, action: :update, owner: current_user, params: allowed_params.to_h)
    end
    permissions.update_all(allowed_params.to_h)
    render json: permissions
  end

  private

  def allowed_params
    params.require(:permission).permit(:privilege, :bypass_fogging, :bypass_delay)
  end

  def require_ownership
    if params[:id]
      render status: 403, json: { error: 'You do not control that permission' } unless user_owns_permission?
    else
      params[:id] = params[:device_id]
      render status: 403, json: { error: 'You do not control that device' } unless user_owns_device?
    end
  end
end
