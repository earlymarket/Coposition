class Api::V1::Users::ApprovalsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  def create
  	# For some reason respond_with doesn't work here
  	# TODO: research why
    render json: @dev.request_approval_from(@user)
  end

end