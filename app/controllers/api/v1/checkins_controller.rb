class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  skip_before_filter :find_user, only: :create
  before_action :device_exists?, only: :create
  before_action :check_user_approved_approvable, :find_device, except: :create

  def index
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 1000
    checkins = @user.get_checkins(@permissible, @device) \
      .paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(checkins)
    checkins = checkins.includes(:device).map do |checkin|
      checkin.resolve_address(@permissible, params[:type])
    end
    render json: checkins
  end

  def last
    checkin = @user.get_checkins(@permissible, @device).first
    checkin = checkin.resolve_address(@permissible, params[:type]) if checkin
    checkin ? (render json: [checkin]) : (render json: [])
  end

  def app_index
    checkins = @device ? @device.checkins : @user.checkins
    checkins = checkins.includes(:device).map do |checkin|
      checkin.reverse_geocode!
    end if params[:type] == 'address'
    render json: checkins
  end

  def create
    checkin = @device.checkins.create(allowed_params)
    if checkin.save
      render json: [checkin]
    else
      render status: 400, json: { message: 'You must provide a lat and lng' }
    end
  end

  private

    def device_exists?
      if (@device = Device.find_by(uuid: request.headers['X-UUID'])).nil?
        render status: 400, json: { message: 'You must provide a valid uuid' }
      end
    end

    def allowed_params
      params.require(:checkin).permit(:lat, :lng, :created_at, :fogged)
    end

    def find_device
      if params[:device_id] then @device = Device.find(params[:device_id]) end
    end

end
