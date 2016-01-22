class Developers::ApprovalsController < ApplicationController

  before_action :authenticate_developer!

  def index
    @approvals = current_developer.pending_approvals
    @users = current_developer.users
  end

  def new
    @approval = Approval.new
  end

  def create
    if current_developer.request_approval_from User.find_by(email: allowed_params["user"])
      flash[:notice] = "Successfully sent" 
    else
      flash[:alert] = "Approval request already sent"
    end
    redirect_to new_developers_approval_path
  end

  def allowed_params
    params.require(:approval).permit(:user)
  end

end
