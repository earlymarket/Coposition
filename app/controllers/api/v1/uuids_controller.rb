class Api::V1::UuidsController < Api::ApiController
  respond_to :json

  skip_before_action :find_user

  def show
    device = Device.create
    @dev.configs.create(device_id: device.id)
    respond_with uuid: device.uuid
  end
end
