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
    email = allowed_params[:user]
    user = User.find_by(email: email)
    approval = Approval.link(user, current_developer, 'Developer') if user
    approval && approval.id ? flash[:notice] = 'Successfully sent' : flash[:alert] = 'Error creating approval'
    current_developer.notify_if_subscribed('new_approval', zapier_data(email, user))
    redirect_to new_developers_approval_path
  end

  private

  def allowed_params
    params.require(:approval).permit(:user)
  end

  def zapier_data(email, user)
    zapier_data = { email: email }
    return [zapier_data] unless user
    [zapier_data.merge(user.public_info.as_json).merge(user.approval_for(current_developer).as_json)]
  end
end
