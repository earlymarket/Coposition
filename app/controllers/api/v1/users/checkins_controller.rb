class Api::V1::Users::CheckinsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_approvable, :find_device
  before_action :permissible_has_privilege?, only: [:index, :last]

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
    checkin = resolve checkin if checkin
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
        checkin.get_data unless checkin.device.permission_for(@permissible).bypass_fogging
        checkin
      else
        checkin.slice(:id, :uuid, :lat, :lng, :created_at)
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

    def get_checkins
      if @device
        @device.checkins_for(@permissible)
      else
        # flatten takes ages, everything else is rapid
        # alternative, only get since approval date for all devices:
        # approval_date = user.approval_for(permissible).approval_date
        # @user.checkins.where("created_at > ?", approval_date)
        checkins = []
        @user.devices.each do |device|
          checkins << device.checkins_for(@permissible)
        end
        checkins = checkins.flatten
        Checkin.where(id: checkins.map(&:id))
      end
    end

end
