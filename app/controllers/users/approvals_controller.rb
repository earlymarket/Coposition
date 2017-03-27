class Users::ApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_url_user?

  def new
    @approval = Approval.new
    @approval.approvable_type = params[:approvable_type]
    @developers = Developer.all.pluck(:company_name)
    @users = User.all.pluck(:username)
  end

  def create
    result = Users::Approvals::CreateUserApproval.call(
      current_user: current_user,
      approvable: approval_params[:approvable]
    )
    approvals_presenter_and_gon("User") if result.success?
    redirect_to(result.path, result.message)
  end

  def apps
    approvals_presenter_and_gon('Developer')
    render 'approvals'
  end

  def friends
    approvals_presenter_and_gon('User')
    render 'approvals'
  end

  def approve
    result = Users::Approvals::UpdateApproval.call(
      current_user: current_user,
      params: params
    )
    approvals_presenter_and_gon(result.approvable_type)
    return unless result.approvable_type == 'Developer'
    result.approvable.notify_if_subscribed('new_approval', approval_zapier_data(result.approval))
  end

  def reject
    result = Users::Approvals::RejectApproval.call(
      current_user: current_user,
      params: params
    )
    approvals_presenter_and_gon(result.approvable_type)
    render 'approve'
  end

  private

  def approval_params
    params
      .require(:approval)
      .permit(:approvable, :approvable_type)
  end
end
