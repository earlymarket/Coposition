class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:update]

  before_action :authenticate, :find_user
  before_action :check_user, only: :update

  def create
    type = allowed_params[:approvable_type]
    model = model_find(type)
    approvable = model.find(allowed_params[:approvable])
    if resource_exists?(type,approvable)
      Approval.link(@user, approvable, type)
      if (req_from_coposition_app? && (@user.has_request_from(approvable) || type == 'Developer'))
        Approval.accept(@user, approvable, type)
      end
      approval = @user.approval_for(approvable)
      render json: approval
    end
  end

  def update
    approval = Approval.where(id: params[:id], user: @user).first
    if approval_exists? approval
      if allowed_params[:status] == 'accepted'
        Approval.accept(@user, approval.approvable, approval.approvable_type)
        render json: approval
      else
        approval.destroy
        render status: 200, json: { message: 'Approval Destroyed' }
      end
    end
  end

  def index
    render json: @user.approvals
  end

  def status
  	respond_with approval_status: @user.approval_status_for(@dev)
  end

  private
    def allowed_params
      params.require(:approval).permit(:user, :approvable, :approvable_type, :status)
    end

    def check_user
      unless current_user?(params[:user_id])
        render status: 403, json: { message: 'Incorrect User' }
      end
    end

end
