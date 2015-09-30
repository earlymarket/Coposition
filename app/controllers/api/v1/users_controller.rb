class Api::V1::UsersController < Api::ApiController
  respond_to :json

  before_action :authenticate

  def index
    @users = User.all.select(:id, :username)
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user if @user.approved_developer?(@dev)
  end

end