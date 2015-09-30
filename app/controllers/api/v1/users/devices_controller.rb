class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer


  def index
    @devices = @user.devices.select(:id, :name)
    respond_with @devices
  end

  def show
    respond_with @user.devices.where(id: params[:id]).select(:id, :name)
  end

end