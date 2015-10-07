class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :find_user

  def create
  	# For some reason respond_with doesn't work here
  	# TODO: research why
    render json: @dev.request_approval_from(@user)
  end

  def status
  	respond_with approval_status: @dev.approval_status_for(@user) 
  end	

end