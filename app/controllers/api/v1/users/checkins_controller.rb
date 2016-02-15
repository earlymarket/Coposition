class Api::V1::Users::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_developer, :find_device, :find_owner
  before_action :check_privilege, only: [:index, :last]

  def index
    # TODO: Should check privilege for each device, not list ALL the checkins!
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 30
    checkins = @owner.checkins.order('created_at DESC').paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(checkins)
    checkins = checkins.map do |checkin|
      resolve checkin
    end
    render json: checkins
  end

  def last
    checkin = @owner.checkins.last
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
        checkin.get_data
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
    if device.privilege_for(@dev) == "disallowed"
      head status: :unauthorized, json: { message: 'Device privilege set to disallowed' }
      return false
    elsif device.privilege_for(@dev) == "last_only" && params[:action] == 'index'
      head status: :unauthorized, json: { message: 'Device privilege set to last only' }
      return false
    else
    end
  end

  def check_show_history
  end

  def check_bypass_fogging
  end
end
