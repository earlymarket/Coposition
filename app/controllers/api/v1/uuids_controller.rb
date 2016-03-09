class Api::V1::UuidsController < Api::ApiController
  respond_to :json

  def show
    respond_with uuid: Device.create.uuid
  end
end
