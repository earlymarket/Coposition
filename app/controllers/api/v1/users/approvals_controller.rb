class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, except: :create

  def create
    resource_exists?(approvable_type, approvable)
    approval = Approval.link(@user, approvable, approvable_type)
    accept_if_friend_request_or_adding_developer if req_from_coposition_app?
    CreateActivity.call(entity: approval, action: :create, owner: @user, params: params.to_h) if approval.id
    @dev.notify_if_subscribed("new_approval", approval_zapier_data(approval))
    render json: approval
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
    req_from_coposition_app? ? allowed_params[:approvable_type] : "Developer"
  end

  def approvable
    if req_from_coposition_app?
      model_find(approvable_type).find_by(email: allowed_params[:approvable]) || model_find(approvable_type).find(allowed_params[:approvable])
    else
      @dev
    end
  end

  def model_find(type)
    [User, Developer].find { |model| model.name == type.titleize }
  end

  def accept_if_friend_request_or_adding_developer
    return unless @user.request_from?(approvable) || approvable_type == "Developer"
    Approval.accept(@user, approvable, approvable_type)
  end
end
