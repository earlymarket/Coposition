class Api::V1::UuidsController < Api::ApiController
  respond_to :json

  skip_before_action :find_user, :update_last_mobile_visit_at

  def show
    device = Device.create
    @dev.configs.create(device_id: device.id)
    respond_with uuid: device.uuid
  end
end
