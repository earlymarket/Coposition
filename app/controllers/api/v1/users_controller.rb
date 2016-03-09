class Api::V1::UsersController < Api::ApiController
  respond_to :json

  before_action :authenticate
  before_action :check_user_approved_approvable, except: [:index]

  def index
    respond_with User.all.select(:id, :username)
  end

  def show
    respond_with @user
  end
end
