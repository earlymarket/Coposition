class Users::CreateDevApprovalsController < ApplicationController
  before_action :authenticate_user!

  def create
    developer = Developer.find_by(company_name: allowed_params[:approvable])
    approval = Approval.add_developer(current_user, developer) if developer
    return unless approval_created?(developer, approval)
    approvals_presenter_and_gon('Developer')
    developer.notify_if_subscribed('new_approval', approval_zapier_data(approval))
    redirect_to(user_apps_path, notice: 'Developer approved')
  end

  private

  def allowed_params
    params.require(:approval).permit(:approvable)
  end

  def approval_created?(developer, approval)
    return true if developer && approval.save
    errors = approval ? approval.errors.get(:base).first : 'Developer not found'
    redirect_to new_user_approval_path(approvable_type: 'Developer'), alert: "Error: #{errors}"
    false
  end
end
