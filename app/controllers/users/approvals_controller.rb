class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user!

  def index
    @approvals = current_user.approvals
    @pending_approvals = current_user.pending_approvals
  end

  def approve
    @approval = Approval.where(id: params[:id], 
      user: current_user).first
    @approval.approve!
  end

  def deny
    binding.pry
  end

end
