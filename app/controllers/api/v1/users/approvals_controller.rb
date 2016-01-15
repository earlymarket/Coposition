class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:update]

  before_action :authenticate, :find_user
  before_action :check_user, only: :update

  def create
  	# For some reason respond_with doesn't work here
  	# TODO: research why
    @dev.request_approval_from(@user).select(:id, :approved, :pending).first
    approval = Approval.where(user: @user, developer: @dev)
    render json: approval.to_json
  end

  def update
    approval = Approval.where(id: params[:id], user: @user).first
    if approval
      approval.update(allowed_params)
      @user.approve_devices_for_developer(@dev) if allowed_params[:approved]
      render json: approval
    else
      render status: 400, json: { message: 'Approval does not exist/belong to user' }
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
      params.require(:approval).permit(:approved,:pending)
    end

    def check_user
      unless current_user?(params[:user_id])
        render status: 403, json: { message: 'Incorrect User' } 
      end
    end	

end