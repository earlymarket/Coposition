class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_user, only: :index

  def new
    @approval = Approval.new
    @approval.approvable_type = params[:approvable_type]
  end

  def create
    type = allowed_params[:approvable_type]
    model = model_find(type)
    approvable = model.find_by(email: allowed_params[:approvable])
    if approvable
      flash[:notice] = "Approval already exists"
      flash[:notice] = "Request sent" if Approval.link(current_user, approvable, type)
      if (type == 'Developer') || (current_user.friend_requests.include?(approvable))
        flash[:notice] = "#{type} added!" if Approval.accept(current_user, approvable, type)
      end
      redirect_to user_dashboard_path
    else
      invalid_payload("User/Developer not found", new_user_approval_path)
    end
  end

  def applications
    @approved_devs = current_user.developers
    @pending_approvals = current_user.pending_approvals
    # Redirect if foreign app failed to create a pending approval.
    if @approved_devs.length == 0 && @pending_approvals.length == 0 && params[:redirect]
      developer = Developer.find_by(api_key: params[:api_key])
      Approval.link(current_user, developer, 'Developer')
      @pending_approvals = current_user.pending_approvals
    elsif @pending_approvals.length == 0 && params[:redirect]
      redirect_to params[:redirect]
    end
  end

  def friends
    @friends = current_user.friends
    @friend_requests = current_user.friend_requests
    @pending_friends = current_user.pending_friends
  end

  def approve
    @approval = Approval.where(id: params[:id],
      user: current_user).first
    Approval.accept(current_user, @approval.approvable, @approval.approvable_type)
    @approved_devs = current_user.developers
    @friends = current_user.friends
    @pending_approvals = current_user.pending_approvals
    @friend_requests = current_user.friend_requests
    @pending_friends = current_user.pending_friends
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
    @approved_devs = current_user.developers
    @friends = current_user.friends
    @pending_approvals = current_user.pending_approvals
    @friend_requests = current_user.friend_requests
    @pending_friends = current_user.pending_friends
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

end
