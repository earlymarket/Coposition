class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  def create
    render json: Checkin.create(allowed_params)
  end

  private

  def allowed_params
    params.require(:checkin).permit(:uuid, :lat, :lng)
  end

end