class Api::V1::UsersController < Api::ApiController
  respond_to :json

  skip_before_filter [:find_user, :authenticate], only: :auth
  before_action :check_user_approved_approvable

  def show
    @user = @user.public_info unless req_from_coposition_app?
    respond_with @user
  end

  def auth
    user = User.find_by(email: params[:email], password: params[:password])
    if user
      render status: 204
    else
      render status: 400
    end
  end
end
