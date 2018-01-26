class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User

  def create
    result = CreateApproval.call(user: @user, approvable: allowed_params[:approvable], type: approvable_type)
    if result.success
      render json: result.approval
    else
      render status: 404, json: { error: "Error creating approval" }
    end
  end

  def update
    result = ::Users::Approvals::UpdateApproval.call(current_user: @user, params: params)
    if result.success?
      if result.approvable_type == "Developer"
        result.approvable.notify_if_subscribed("new_approval", approval_zapier_data(result.approval))
      end
      render json: result.approval.reload
    else
      render status: 404, json: { error: "Approval does not exist" }
    end
  end

  def destroy
    result = ::Users::Approvals::DestroyApproval.call(current_user: @user, params: params)
    if result.success?
      render status: 200, json: { message: "Approval Destroyed" }
    else
      render status: 404, json: { error: "Approval does not exist" }
    end
  end

  def index
    approvals = if params[:type]
      params[:type] == "friends" ? @user.friend_approvals : @user.developer_approvals
    else
      @user.approvals
    end
    render json: approvals
  end

  def status
    respond_with approval_status: @user.approval_for(@dev).status
  end

  private

  def allowed_params
    params.require(:approval).permit(:user, :approvable, :approvable_type, :status)
  end

  def approvable_type
    allowed_params[:approvable_type]
  end
end
