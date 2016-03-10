class Api::V1::UuidsController < Api::ApiController
  respond_to :json

  skip_before_filter :find_user

  def show
    respond_with uuid: Device.create.uuid
  end
end
