class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  def index
    respond_with @user.devices.select(:id, :name).preload(:last_checkin)
  end

  def show
    respond_with @user.devices.where(id: params[:id]).select(:id, :name)
  end

end