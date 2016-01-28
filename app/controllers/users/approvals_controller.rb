class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user! 
  before_action :check_user, only: :index

  def new
    @approval = Approval.new
  end

  def create
    type = allowed_params[:approvable_type]
    model = [User, Developer].find { |x| x.name == type.titleize}
    approvable = model.find_by(email: allowed_params[:approvable])
    if approvable
      flash[:notice] = "Approval already exists"
      flash[:notice] = "Request sent" if Approval.link(current_user.id, approvable.id, type)
      if (type == 'Developer') || (current_user.friend_requests.include?(approvable))
        flash[:notice] = "User/Developer added!" if Approval.accept(current_user.id, approvable.id, type)
      end
      redirect_to user_approvals_path
    else
      invalid_payload("User/Developer not found", new_user_approval_path) 
    end
  end

  def index
    @approved_devs = current_user.developers
    @friends = current_user.friends
    @friend_requests = current_user.friend_requests
    @pending_friends = current_user.pending_friends
    @pending_approvals = current_user.pending_approvals
    # Redirect if foreign app failed to create a pending approval.
    if @approved_devs.length == 0 && @pending_approvals.length == 0 && params[:redirect]
      developer = Developer.find_by(api_key: params[:api_key])
      Approval.link(current_user.id, developer.id, 'Developer')
      @pending_approvals = current_user.pending_approvals
    elsif @pending_approvals.length == 0 && params[:redirect]
      redirect_to params[:redirect]
    end
  end

  def approve
    @approval = Approval.where(id: params[:id], 
      user: current_user).first
    @approval.approve!
    @approved_devs = current_user.developers
  end

  def reject
    @approval = Approval.where(id: params[:id], 
      user: current_user).first
    @approval.destroy
    @approved_devs = current_user.developers
    render "users/approvals/approve"
  end

  private

    def check_user
      unless current_user?(params[:user_id])
        flash[:notice] = "You are signed in as #{current_user.username}"
        if params[:origin]
          developer = Developer.find_by(api_key: params[:api_key])
          redirect_to developer.redirect_url+"?copo_user=#{current_user.username}"
        else
          redirect_to root_path
        end
      end
    end

    def allowed_params
      params.require(:approval).permit(:approvable, :approvable_type)
    end

end
