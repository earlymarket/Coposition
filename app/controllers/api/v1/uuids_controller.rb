class Api::V1::UuidsController < Api::ApiController
  respond_to :json

  before_action :authenticate

  def show
    respond_with uuid: Device.create.uuid
  end 
end
