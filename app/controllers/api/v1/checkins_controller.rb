class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  skip_before_filter :find_user, :authenticate
  before_action :device_exists?

  def create
    checkin = @device.checkins.create(allowed_params)
    if checkin.id
      render json: [checkin]
    else
      render status: 400, json: { message: 'You must provide a valid uuid, lat and lng' }
    end
  end

  private

    def device_exists?
      if request.headers['X-UUID'] then @device = Device.find_by(uuid: request.headers['X-UUID']) end
    end

    def allowed_params
      params.require(:checkin).permit(:lat, :lng)
    end

end
