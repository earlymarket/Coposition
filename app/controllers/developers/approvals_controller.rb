class Developers::ApprovalsController < ApplicationController
  before_action :authenticate_developer!

  def index
    @pending = current_developer.pending_approvals
    @users = current_developer.users
  end

  def new
    @approval = Approval.new
  end

  def create
    user = User.find_by(email: allowed_params[:user])
    approval = Approval.link(user, current_developer, 'Developer') if user
    if approval && approval.id
      flash[:notice] = 'Successfully sent'
    else
      flash[:alert] = 'Error creating approval'
    end
    redirect_to new_developers_approval_path
  end

  private

  def allowed_params
    params.require(:approval).permit(:user)
  end

  def check_subscriptions
    if current_developer.subscriptions.where(event: 'create_approval').present?
    end
  end
end
