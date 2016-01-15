class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user!

  def index
    @approved_devs = current_user.approved_developers
    @pending_approvals = current_user.pending_approvals
  end

  def approve
    @approval = Approval.where(id: params[:id], 
      user: current_user).first
    @approval.approve!
    @approved_devs = current_user.approved_developers
  end

  def reject
    @approval = Approval.where(id: params[:id], 
      user: current_user).first
    @approval.reject!
    @approved_devs = current_user.approved_developers
    render "users/approvals/approve"
  end

end
