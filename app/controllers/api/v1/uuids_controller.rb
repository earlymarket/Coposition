class Api::V1::UuidController < Api::ApiController
  respond_to :json

  before_action :authenticate

  def show
    respond_with Device.create
  end 
end
