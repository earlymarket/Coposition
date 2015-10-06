class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  def create
    respond_with @dev.request_approval_from(@user)
  end

end