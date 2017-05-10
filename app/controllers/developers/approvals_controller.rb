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
    result = Developers::Approvals::CreateApproval.call(developer: current_developer, params: allowed_params)
    if result.success?
      flash[:notice] = "Successfully sent"
      current_developer.notify_if_subscribed("new_approval", approval_zapier_data(result.approval))
    else
      flash[:alert] = result.alert
    end
    redirect_to new_developers_approval_path
  end

  def destroy
    @approval = current_developer.approvals.find(params[:id])
    user = @approval.user
    user.destroy_permissions_for(current_developer)
    @approval.destroy
  end

  private

  def allowed_params
    params.require(:approval).permit(:user)
  end
end
