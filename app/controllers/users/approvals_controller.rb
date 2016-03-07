class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_user, only: :index

  def new
    @approval = Approval.new
    @approval.approvable_type = params[:approvable_type]
    @developers = Developer.all.pluck(:email)
    @users = User.all.pluck(:email)
  end

  def create
    type = allowed_params[:approvable_type]
    if approvable(type)
      approval = Approval.construct(current_user, approvable(type), type)
      if approval.save
        flash[:notice] = "Approval created"
        redirect_to user_dashboard_path
      else
        invalid_payload("Error: #{approval.errors.get(:base).first}", new_user_approval_path(approvable_type: type))
      end
    else
      invalid_payload("User/Developer not found", new_user_approval_path(approvable_type: type))
    end
  end

  def apps
    @apps = current_user.developers
    # Redirect if foreign app failed to create a pending approval.
    if @apps.length == 0 && current_user.pending_approvals.length == 0 && params[:redirect]
      developer = Developer.find_by(api_key: params[:api_key])
      Approval.link(current_user, developer, 'Developer')
    elsif current_user.pending_approvals.length == 0 && params[:redirect]
      redirect_to params[:redirect]
    end
  end

  def friends
    @friends = current_user.friends
  end

  def approve
    @approval = Approval.where(id: params[:id],
      user: current_user).first
    Approval.accept(current_user, @approval.approvable, @approval.approvable_type)
    @apps = current_user.developers
    @friends = current_user.friends
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
    respond_to do |format|
      format.html { redirect_to user_approvals_path }
      format.js { render "approve" }
    end
  end

  private

    def check_user
      unless current_user?(params[:user_id])
        developer = Developer.find_by(api_key: params[:api_key])
        redirect_to developer.redirect_url+"?copo_user=#{current_user.username}"
      end
    end

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
