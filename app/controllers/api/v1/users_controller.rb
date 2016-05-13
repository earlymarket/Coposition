class Api::V1::UsersController < Api::ApiController
  respond_to :json

  skip_before_filter :find_user, only: :index
  before_action :check_user_approved_approvable, only: :show

  def index
    respond_with User.all.select(:id, :username)
  end

  def show
    respond_with @user.public_info
  end
end
