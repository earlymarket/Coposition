class Users::ApprovalsController < ApplicationController
  before_action :authenticate_user!

  def new
    @approval = Approval.new
    @approval.approvable_type = params[:approvable_type]
    @developers = Developer.all.pluck(:company_name)
    @users = User.all.pluck(:username)
  end

  def create
    approvable_type = allowed_params[:approvable_type]
    if approvable(approvable_type)
      approval = Approval.construct(current_user, approvable(approvable_type), approvable_type)
      if approval.save
        @presenter = ::Users::ApprovalsPresenter.new(current_user, approvable_type)
        gon.push(@presenter.gon)
        if approvable_type == 'User'
          redirect_to(user_friends_path, notice: 'Friend request sent')
        else
          redirect_to(user_apps_path, notice: 'Developer approved')
        end
      else
        redirect_to new_user_approval_path(approvable_type: approvable_type), alert: "Error: #{approval.errors.get(:base).first}"
      end
    elsif approvable_type == 'User'
      UserMailer.invite_email(allowed_params[:approvable]).deliver_now
      redirect_to user_dashboard_path, notice: 'User not signed up with Coposition, invite email sent!'
    else
      redirect_to new_user_approval_path(approvable_type: approvable_type), alert: 'Developer not found'
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
    @approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = @approval.approvable_type
    Approval.accept(current_user, @approval.approvable, approvable_type)
    @presenter = ::Users::ApprovalsPresenter.new(current_user, approvable_type)
    gon.push(@presenter.gon)
    respond_to do |format|
      format.html { redirect_to user_approvals_path }
      format.js
    end
  end

  def reject
    @approval = Approval.find_by(id: params[:id], user: current_user)
    approvable_type = @approval.approvable_type
    current_user.destroy_permissions_for(@approval.approvable)
    if approvable_type == 'User'
      Approval.find_by(user: @approval.approvable, approvable: @approval.user, approvable_type: 'User').destroy
    end
    @approval.destroy
    @presenter = ::Users::ApprovalsPresenter.new(current_user, approvable_type)
    gon.push(@presenter.gon)
    respond_to do |format|
      format.html { redirect_to user_approvals_path }
      format.js { render 'approve' }
    end
  end

  private

  def allowed_params
    params.require(:approval).permit(:approvable, :approvable_type)
  end

  def approvable(type)
    if type == 'Developer'
      Developer.find_by(company_name: allowed_params[:approvable])
    elsif type == 'User'
      User.find_by(email: allowed_params[:approvable])
    end
  end
end
