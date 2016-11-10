class Api::V1::CheckinsController < Api::ApiController
  respond_to :json

  skip_before_action :find_user, only: :create
  before_action :device_exists?, only: :create
  before_action :check_user_approved_approvable, :find_device, except: :create

  def index
    per_page = params[:per_page].to_i <= 1000 ? params[:per_page] : 1000
    checkins = @user.safe_checkin_info(
      copo_app: req_from_coposition_app?,
      permissible: @permissible,
      device: @device,
      page: params[:page],
      per_page: per_page,
      type: params[:type],
      time_unit: params[:time_unit],
      time_amount: params[:time_amount],
      date: params[:date],
      near: params[:near],
      action: action_name
    )
    unsanitized_checkins = @user.get_user_checkins_for(@permissible).paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(unsanitized_checkins)
    render json: checkins
  end

  def last
    checkin = @user.safe_checkin_info(
      copo_app: req_from_coposition_app?,
      permissible: @permissible,
      device: @device,
      type: params[:type],
      date: params[:date],
      near: params[:near],
      action: action_name
    )
    render json: checkin
  end

  def places
    per_page = params[:per_page].to_i <= 1000 ? params[:per_page] : 1000
    checkins = @user.get_user_checkins_for(@permissible)
    places = checkins.unscope(:order)
                     .pluck('DISTINCT ON (checkins.fogged_area) checkins.fogged_area, checkins.created_at')
                     .sort { |checkin, next_checkin| next_checkin[1] <=> checkin[1] }
                     .map { |checkin| checkin[0] }
                     .paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(places)
    render json: places
  end

  def create
    checkin = @device.checkins.create(allowed_params)
    if checkin.save
      @device.notify_subscribers('new_checkin', checkin)
      config = @dev.configs.find_by(device_id: @device.id)
      render json: { data: [checkin], config: config }
    else
      render status: 400, json: { error: 'You must provide a lat and lng' }
    end
  end

  private

  def device_exists?
    return unless (@device = Device.find_by(uuid: request.headers['X-UUID'])).nil?
    render status: 400, json: { error: 'You must provide a valid uuid' }
  end

  def allowed_params
    params.require(:checkin).permit(:lat, :lng, :created_at, :fogged)
  end

  def find_device
    @device = Device.find(params[:device_id]) if params[:device_id]
  end
end
