class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: [:update]

  before_action :check_user, only: :update

  def create
    if req_from_coposition_app?
      resource_exists?(approvable_type,approvable)
      Approval.link(@user, approvable, approvable_type)
      if @user.has_request_from(approvable) || approvable_type == 'Developer'
        Approval.accept(@user, approvable, approvable_type)
      end
      approval = @user.approval_for(approvable)
    else
      Approval.link(@user, @dev, 'Developer')
      approval = @user.approval_for(@dev)
    end
    render json: approval
  end


  def update
    approval = Approval.where(id: params[:id], user: @user).first
    if approval_exists? approval
      if allowed_params[:status] == 'accepted'
        Approval.accept(@user, approval.approvable, approval.approvable_type)
        render json: approval.reload
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
  	respond_with approval_status: @user.approval_for(@dev).status
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

    def approvable_type
      allowed_params[:approvable_type]
    end

    def approvable
      model_find(approvable_type).find(allowed_params[:approvable])
    end

    def model_find(type)
      [User, Developer].find { |model| model.name == type.titleize}
    end

end
