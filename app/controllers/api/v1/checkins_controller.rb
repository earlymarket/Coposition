class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  def create
    return unless valid_request?
    render json: Checkin.create(allowed_params)
  end

  private

    def allowed_params
      params.require(:checkin).permit(:uuid, :lat, :lng)
    end

    def valid_request?
      if allowed_params[:uuid].nil? or allowed_params[:lat].nil? or allowed_params[:lng].nil?
        render status: 400, json: { message: 'The request MUST contain a UUID, latitude and longitude.' }
        return false
      end
      true
    end

end