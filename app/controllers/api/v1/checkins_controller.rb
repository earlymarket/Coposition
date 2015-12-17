class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  def create
    @checkin = Checkin.create(allowed_params)
    if @checkin.id
      render json: @checkin.to_json
    else
      render status: 400, json: { message: 'You must provide a UUID, lat and lng' }
    end
  end

  private

  def allowed_params
    params.require(:checkin).permit(:uuid, :lat, :lng)
  end

end