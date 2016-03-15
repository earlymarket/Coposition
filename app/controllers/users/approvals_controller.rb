class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user!

  def new
    @approval = Approval.new
    @approval.approvable_type = params[:approvable_type]
    @developers = Developer.all.pluck(:company_name)
    @users = User.all.pluck(:username)
  end

  def create
    type = allowed_params[:approvable_type]
    if approvable(type)
      approval = Approval.construct(current_user, approvable(type), type)
      if approval.save
        redirect_to user_dashboard_path, notice: "Approval created"
      else
        redirect_to new_user_approval_path(approvable_type: type), alert: "Error: #{approval.errors.get(:base).first}"
      end
    elsif type == 'User'
      UserMailer.invite_email(allowed_params[:approvable]).deliver_now
      redirect_to user_dashboard_path, notice: "User not signed up with Coposition, invite email sent!"
    else
      redirect_to new_user_approval_path(approvable_type: type), alert: "Developer not found"
    end
  end

  def apps
    @apps = current_user.developers
    @pending = current_user.developer_requests
    @devices = current_user.devices.includes(:permissions)
    gon.current_user_id = current_user.id
    gon.permissions = @devices.map { |device| device.permissions }
  end

  def friends
    @friends = current_user.friends
    @pending = current_user.friend_requests
    @devices = current_user.devices.includes(:permissions)
    gon.current_user_id = current_user.id
    gon.permissions = @devices.map { |device| device.permissions }
  end

  def approve
    @approval = Approval.where(id: params[:id],
      user: current_user).first
    Approval.accept(current_user, @approval.approvable, @approval.approvable_type)
    @apps = current_user.developers
    @friends = current_user.friends
    @devices = current_user.devices.includes(:permissions)
    respond_to do |format|
      format.html { redirect_to user_approvals_path }
      format.js
    end
  end

  def reject
    @approval = Approval.where(id: params[:id],
      user: current_user).first
    current_user.destroy_permissions_for(@approval.approvable)
    if @approval.approvable_type == 'User'
      Approval.where(user: @approval.approvable, approvable: @approval.user, approvable_type: 'User').first.destroy
    end
    @approval.destroy
    @apps = current_user.developers
    @friends = current_user.friends
    @devices = current_user.devices.includes(:permissions)
    respond_to do |format|
      format.html { redirect_to user_approvals_path }
      format.js { render "approve" }
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
