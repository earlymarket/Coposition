class  Api::V1::Users::PermissionsController < Api::ApiController
  respond_to :json
  
  acts_as_token_authentication_handler_for User
  
  before_action :require_ownership

  def update
    permission = Permission.find(params[:id])
    permission.update(allowed_params)
    render json: permission
  end

  private
    def allowed_params
      params.require(:permission).permit(:privilege, :bypass_fogging, :show_history)
    end

    def require_ownership
      unless user_owns_permission?
        render status: 403, json: { message: "You do not control that permission" }
      end
    end
end
