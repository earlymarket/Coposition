class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  # TODO: Think about refactoring this

  def index
    list = []
    @user.devices.except(:fogged).map do |dev|
      if dev.privilege_for(@dev) == "complete"
        hash = dev.as_json
        hash[:last_checkin] = dev.checkins.last.get_data
        list << hash
      end
    end
    respond_with list
  end

  def show
    list = []
    @user.devices.where(id: params[:id]).except(:fogged).map do |dev|
      if dev.privilege_for(@dev) == "complete"
        hash = dev.as_json
        hash[:last_checkin] = dev.checkins.last.get_data
        list << hash
      else
        return head status: :unauthorized
      end
    end
    respond_with list
  end

end