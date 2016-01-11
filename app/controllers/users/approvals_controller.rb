class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user! 
  before_action :check_user, only: :index

  def index
    @approved_devs = current_user.approved_developers
    @pending_approvals = current_user.pending_approvals
    if @pending_approvals.length == 0 && params[:redirect]
      redirect_to params[:redirect]
    end
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

  def check_user
    redirect_to new_user_session_path unless current_user?(params[:user_id])
  end
end
