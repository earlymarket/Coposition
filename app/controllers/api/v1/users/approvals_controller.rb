class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, except: :create

  before_action :check_user, only: :update

  def create
    resource_exists?(approvable_type, approvable)
    Approval.link(@user, approvable, approvable_type)
    accept_if_friend_request_or_adding_developer if req_from_coposition_app?
    approval = @user.approval_for(approvable)
    @dev.notify_if_subscribed('new_approval', approval_zapier_data(approval))
    render json: approval
  end

  def update
    approval = Approval.find_by(id: params[:id], user: @user)
    return unless approval_exists? approval
    approvable = approval.approvable
    type = approval.approvable_type
    Approval.accept(@user, approvable, type)
    render json: approval.reload
    approvable.notify_if_subscribed('new_approval', approval_zapier_data(approval)) if type == 'Developer'
  end

  def destroy
    approval = Approval.find_by(id: params[:id], user: @user)
    return unless approval_exists? approval
    @user.destroy_permissions_for(approval.approvable)
    approval.destroy
    render status: 200, json: { message: 'Approval Destroyed' }
  end

  def index
    approvals = if params[:type]
                  params[:type] == 'friends' ? @user.friend_approvals : @user.developer_approvals
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

  def check_user
    render status: 403, json: { error: 'Incorrect User' } unless current_user?(params[:user_id])
  end

  def approvable_type
    req_from_coposition_app? ? allowed_params[:approvable_type] : 'Developer'
  end

  def approvable
    req_from_coposition_app? ? model_find(approvable_type).find(allowed_params[:approvable]) : @dev
  end

  def model_find(type)
    [User, Developer].find { |model| model.name == type.titleize }
  end

  def accept_if_friend_request_or_adding_developer
    if @user.request_from?(approvable) || approvable_type == 'Developer'
      Approval.accept(@user, approvable, approvable_type)
    end
  end
end
