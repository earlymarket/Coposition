class Users::CreateDevApprovalsController < ApplicationController
  before_action :authenticate_user!

  def create
    result = Users::Approvals::CreateDeveloperApproval.call(
      current_user: current_user,
      approvable: allowed_params[:approvable]
    )
    if result.success?
      approvals_presenter_and_gon(approvable_type: "Developer")
      result.developer.notify_if_subscribed("new_approval", approval_zapier_data(result.approval))
      redirect_to(user_apps_path, notice: "App connected")
    else
      redirect_to new_user_approval_path(approvable_type: "Developer"), alert: "Error: #{result.error}"
    end
  end

  private

  def allowed_params
    params.require(:approval).permit(:approvable)
  end
end
