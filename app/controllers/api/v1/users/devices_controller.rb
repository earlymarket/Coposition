class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  # TODO: Think about refactoring this

  def index
    list = []
    @user.devices.select(:id, :name).map do |dev|
    	hash = dev.as_json
    	hash[:last_checkin] = dev.checkins.last
    	list << hash
  	end
  	respond_with list
  end

  def show
    list = []
    @user.devices.where(id: params[:id]).select(:id, :name).map do |dev|
    	hash = dev.as_json
    	hash[:last_checkin] = dev.checkins.last
    	list << hash
  	end
  	respond_with list
  end

end