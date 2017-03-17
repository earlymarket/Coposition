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
    result = CreateApproval.call(
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
    approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = approval.approvable_type
    approvable = approval.approvable
    Approval.accept(current_user, approvable, approvable_type)
    approvals_presenter_and_gon(approvable_type)
    approvable.notify_if_subscribed('new_approval', approval_zapier_data(approval)) if approvable_type == 'Developer'
  end

  def reject
    approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = approval.approvable_type
    approvable = approval.approvable
    current_user.destroy_permissions_for(approvable)
    if approvable_type == 'User'
      approvable.destroy_permissions_for(current_user)
      Approval.where(user: approvable, approvable: current_user, approvable_type: 'User').destroy_all
    end
    approval.destroy
    approvals_presenter_and_gon(approvable_type)
    render 'approve'
  end

  private

  def approval_params
    params
      .require(:approval)
      .permit(:approvable, :approvable_type)
  end
end
