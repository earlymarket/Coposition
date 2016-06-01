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
      @presenter = ::Users::ApprovalsPresenter.new(current_user, 'User')
      gon.push(@presenter.gon)
      redirect_to(user_friends_path, notice: 'Friend request sent')
    end
  end

  def apps
    @presenter = ::Users::ApprovalsPresenter.new(current_user, 'Developer')
    gon.push(@presenter.gon)
    render 'approvals'
  end

  def friends
    @presenter = ::Users::ApprovalsPresenter.new(current_user, 'User')
    gon.push(@presenter.gon)
    render 'approvals'
  end

  def approve
    approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = approval.approvable_type
    Approval.accept(current_user, approval.approvable, approvable_type)
    @presenter = ::Users::ApprovalsPresenter.new(current_user, approvable_type)
    gon.push(@presenter.gon)
  end

  def reject
    approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = approval.approvable_type
    current_user.destroy_permissions_for(approval.approvable)
    if approvable_type == 'User'
      Approval.find_by(user: approval.approvable, approvable: approval.user, approvable_type: 'User').destroy
    end
    approval.destroy
    @presenter = ::Users::ApprovalsPresenter.new(current_user, approvable_type)
    gon.push(@presenter.gon)
    render 'approve'
  end

  private

  def allowed_params
    params.require(:approval).permit(:approvable, :approvable_type)
  end

  def send_email_and_redirect
    UserMailer.invite_email(allowed_params[:approvable]).deliver_now
    redirect_to user_dashboard_path, notice: 'User not signed up with Coposition, invite email sent!'
  end

  def approval_created?(user, approval)
    return true if user && approval.save
    if user.present?
      redirect_to new_user_approval_path(approvable_type: 'User'), alert: "Error: #{approval.errors.get(:base).first}"
    else
      send_email_and_redirect
    end
    false
  end
end
