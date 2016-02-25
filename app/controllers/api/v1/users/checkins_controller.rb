class Api::V1::Users::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_approvable, :find_device
  before_action :permissible_has_privilege?, only: [:index, :last]

  def index
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 1000
    checkins = @user.get_checkins(@permissible,@device).order('created_at DESC').paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(checkins)
    checkins = checkins.map do |checkin|
      resolve checkin
    end
    render json: checkins
  end

  def last
    checkin = @user.get_checkins(@permissible,@device).last
    checkin = resolve checkin if checkin
    render json: [checkin]
  end

  def create
    device = Device.find(params[:device_id])
    checkin = device.checkins.create(allowed_params)
    if checkin.id
      render json: [checkin]
    else
      render status: 400, json: { message: 'You must provide a lat and lng' }
    end
  end

  private

    def allowed_params
      params.require(:checkin).permit(:lat, :lng)
    end

    def resolve checkin
      if params[:type] == "address"
        checkin.reverse_geocode!
        checkin.get_data unless checkin.device.can_bypass_fogging?(@permissible)
        checkin
      else
        checkin.slice(:id, :uuid, :lat, :lng, :created_at, :updated_at, :fogged)
      end
    end

    def permissible_has_privilege?
      if @device
        check_privilege_level(@device)
      else
        @user.devices.each do |device|
          check_privilege_level(device)
        end
      end
    end

    def check_privilege_level(device)
      if device.permission_for(@permissible).privilege == "disallowed"
        render status: 401, json: { permission_status: device.permission_for(@permissible).privilege }
      elsif device.permission_for(@permissible).privilege == "last_only" && params[:action] == 'index'
        render status: 401, json: { permission_status: device.permission_for(@permissible).privilege }
      end
    end

end
