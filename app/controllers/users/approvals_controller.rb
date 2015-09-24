class Users::ApprovalsController < ApplicationController

  before_action :authenticate_user!

  def index
    @approvals = current_user.pending_approvals
  end

end
