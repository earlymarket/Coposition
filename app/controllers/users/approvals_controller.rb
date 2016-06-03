class Users::ApprovalsController < ApplicationController
  before_action :authenticate_user!

  def new
    @approval = Approval.new
    @approval.approvable_type = params[:approvable_type]
    @developers = Developer.all.pluck(:company_name)
    @users = User.all.pluck(:username)
  end

  def create
    user = User.find_by(email: allowed_params[:approvable])
    approval = Approval.add_friend(current_user, user) if user
    if approval_created?(user, approval)
      presenter_and_gon('User')
      redirect_to(user_friends_path, notice: 'Friend request sent')
    end
  end

  def apps
    presenter_and_gon('Developer')
    render 'approvals'
  end

  def friends
    presenter_and_gon('User')
    render 'approvals'
  end

  def approve
    approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = approval.approvable_type
    Approval.accept(current_user, approval.approvable, approvable_type)
    presenter_and_gon(approvable_type)
  end

  def reject
    approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = approval.approvable_type
    approvable = approval.approvable
    current_user.destroy_permissions_for(approvable)
    if approvable_type == 'User'
      Approval.destroy_all(user: approvable, approvable: current_user, approvable_type: 'User')
    end
    approval.destroy
    presenter_and_gon(approvable_type)
    render 'approve'
  end

  private

  def allowed_params
    params.require(:approval).permit(:approvable, :approvable_type)
  end

  def approval_created?(user, approval)
    return true if user && approval.save
    if user.present?
      redirect_to new_user_approval_path(approvable_type: 'User'), alert: "Error: #{approval.errors.get(:base).first}"
    else
      UserMailer.invite_email(allowed_params[:approvable]).deliver_now
      redirect_to user_dashboard_path, notice: 'User not signed up with Coposition, invite email sent!'
    end
    false
  end
end
