class Api::V1::UsersController < Api::ApiController
  respond_to :json

  skip_before_action :find_user, :authenticate,  only: :auth
  before_action :check_user_approved_approvable, only: :show

  def show
    @user = @user.public_info unless req_from_coposition_app?
    respond_with @user
  end

  def auth
    user = User.find_by(webhook_key: request.headers['X-Webhook-Key'])
    if user
      render status: 204, json: { message: 'Success' }
    else
      render status: 400, json: { message: 'Invalid webhook key supplied' }
    end
  end
end
