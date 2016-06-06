class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  skip_before_filter :find_user, only: :create
  before_action :device_exists?, only: :create
  before_action :check_user_approved_approvable, :find_device, except: :create

  def index
    if req_from_coposition_app?
      checkins = copo_app_checkins
    else
      per_page = params[:per_page].to_i <= 1000 ? params[:per_page] : 1000
      checkins = @user.safe_checkin_info({
        permissible: @permissible,
        device: @device,
        page: params[:page],
        per_page: per_page,
        type: params[:type],
        action: action_name
      })
      unsanitized_checkins = @user.get_user_checkins_for(@permissible).paginate(page: params[:page], per_page: per_page)
      paginated_response_headers(unsanitized_checkins)
    end
    render json: checkins
  end

  def last
    if req_from_coposition_app?
      checkin = copo_app_checkins
    else
      checkin = @user.safe_checkin_info({
        permissible: @permissible,
        device: @device,
        type: params[:type],
        action: action_name
      })
    end
    render json: checkin
  end

  def create
    checkin = @device.checkins.create(allowed_params)
    if checkin.save
      @device.notify_subscribers('new_checkin', checkin)
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
    @device = Device.find(params[:device_id]) if params[:device_id]
  end

    def copo_app_checkins
      checkins = @device ? @device.checkins : @user.checkins
      checkins = checkins.limit(1) if action_name == 'last'
      params[:type] == 'address' ? checkins.map(&:reverse_geocode!) : checkins
    end
end
