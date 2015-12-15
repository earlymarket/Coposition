class Api::V1::Users::DevicesController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer

  def index
    list = []
    @user.devices.except(:fogged).map do |devc|
      if devc.privilege_for(@dev) == "complete"
        list << device_checkin_hash(devc)
      end
    end
    respond_with list
  end

  def show
    list = []
    @user.devices.where(id: params[:id]).except(:fogged).map do |devc|
      if devc.privilege_for(@dev) == "complete"
        list << device_checkin_hash(devc)
      else
        return head status: :unauthorized
      end
    end
    respond_with list
  end

  private

    def device_checkin_hash(device)
      hash = device.as_json
      hash[:last_checkin] = device.checkins.last.get_data if device.checkins.exists?
      hash
    end

end