class Api::V1::Users::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :find_owner
  before_action :check_privilege, only: [:index, :last]

  def index
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 30
    checkins = get_checkins.order('created_at DESC').paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(checkins)
    checkins = checkins.map do |checkin|
      resolve checkin
    end
    render json: checkins
  end

  def last
    checkin = get_checkins.last
    checkin = resolve checkin
    render json: [checkin]
  end

  def create
    checkin = Checkin.create(allowed_params)
    if checkin.id
      render json: [checkin]
    else
      render status: 400, json: { message: 'You must provide a UUID, lat and lng' }
    end
  end

  private

  def allowed_params
    params.require(:checkin).permit(:uuid, :lat, :lng)
  end

  def resolve checkin
    if params[:type] == "address"
      checkin.reverse_geocode!
      if checkin.device.permission_for(@dev).bypass_fogging
        checkin
      else
        checkin.get_data
      end
    else
      checkin.slice(:id, :uuid, :lat, :lng, :created_at)
    end
  end

  def check_privilege
    if @device
      check_level(@device)
    else
      @user.devices.each do |device|
        check_level(device)
      end
    end
  end

  def check_level(device)
    if device.permission_for(@dev).privilege == "disallowed"
      head status: :unauthorized, json: { message: 'Device privilege set to disallowed' }
      return false
    elsif device.permission_for(@dev).privilege == "last_only" && params[:action] == 'index'
      head status: :unauthorized, json: { message: 'Device privilege set to last only' }
      return false
    else
    end
  end

  def get_checkins
    approval_date = @user.approval_date_for(@dev)
    if @device.permission_for(@dev).show_history
      checkins = @owner.checkins
    else
      checkins = @owner.checkins.where("created_at > ?", approval_date)
    end
  end
end
