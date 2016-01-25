class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:update]

  before_action :authenticate, :find_user
  before_action :check_user, only: :update

  def create
    @dev.request_approval_from(@user).select(:id, :status).first
    approval = Approval.where(user: @user, approvable_id: @dev.id, approvable_type: 'Developer')
    render json: approval
  end

  def update
    approval = Approval.where(id: params[:id], user: @user).first
    if approval_exists? approval
      approval.update(allowed_params)
      @user.approve_devices_for_developer(@dev) if allowed_params[:status] == 'accepted'
      render json: approval
    end
  end

  def index
    render json: @user.approvals
  end

  def status
  	respond_with approval_status: @dev.approval_status_for(@user) 
  end

  private
    def allowed_params
      params.require(:approval).permit(:status)
    end

    def check_user
      unless current_user?(params[:user_id])
        render status: 403, json: { message: 'Incorrect User' }
      end
    end

end