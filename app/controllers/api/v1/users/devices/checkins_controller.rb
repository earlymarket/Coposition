class Api::V1::Users::Devices::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :check_privilege

  def index
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 30
    checkins = @device.checkins.order('created_at DESC').paginate(page: params[:page], per_page: per_page)
    response['X-Current-Page'] = checkins.current_page.to_json
    response['X-Next-Page'] = checkins.next_page.to_json
    response['X-Total-Entries'] = checkins.total_entries.to_json
    response['X-Per-Page'] = checkins.per_page.to_json
    checkins = checkins.map do |checkin|
      resolve checkin
    end
    render json: checkins.to_json
  end

  def last
    checkin = @device.checkins.last
    checkin = resolve checkin
    render json: checkin.to_json
  end

  def resolve checkin
    if params[:type] == "address"
        checkin.reverse_geocode!
        checkin.get_data
    else
      checkin.slice(:id, :uuid, :lat, :lng, :created_at)
    end
  end

  def create
    checkin = Checkin.create(allowed_params)
    if checkin.id
      render json: checkin.to_json
    else
      render status: 400, json: { message: 'You must provide a UUID, lat and lng' }
    end
  end

  private

  def allowed_params
    params.require(:checkin).permit(:uuid, :lat, :lng)
  end

end
