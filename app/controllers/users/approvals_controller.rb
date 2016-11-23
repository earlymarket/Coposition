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
    user = User.find_by(email: allowed_params[:approvable].downcase)
    approval = Approval.add_friend(current_user, user) if user
    if approval_created?(user, approval)
      approvals_presenter_and_gon('User')
      redirect_to(user_friends_path, notice: 'Friend request sent')
    end
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

  def allowed_params
    params.require(:approval).permit(:approvable, :approvable_type)
  end

  def approval_created?(user, approval)
    return true if user && approval.save
    if user.present?
      redirect_to new_user_approval_path(approvable_type: 'User'), alert: "Error: #{approval.errors[:base].first}"
    else
      UserMailer.invite_email(allowed_params[:approvable]).deliver_now
      redirect_to user_dashboard_path, notice: 'User not signed up with Coposition, invite email sent!'
    end
    false
  end
end
