class Api::V1::UsersController < Api::ApiController
  respond_to :json

  before_action :check_user_approved_approvable

  def show
    @user = @user.public_info unless req_from_coposition_app?
    respond_with @user
  end
end
