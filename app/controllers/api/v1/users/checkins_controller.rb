class Api::V1::Users::CheckinsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User, only: :create

  before_action :check_user_approved_approvable, :find_device
  before_action :check_user, only: :create

  def index
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 1000
    checkins = @user.get_checkins(@permissible, @device).order('created_at DESC') \
      .paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(checkins)
    checkins = checkins.map do |checkin|
      checkin.resolve_address(@permissible, params[:type])
    end
    render json: checkins
  end

  def last
    checkin = @user.get_checkins(@permissible, @device).last
    checkin = checkin.resolve_address(@permissible, params[:type]) if checkin
    if checkin
      render json: [checkin]
    else
      render json: []
    end
  end

  def create
    checkin = @device.checkins.create(allowed_params)
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

    def find_device
      if params[:device_id] then @device = Device.find(params[:device_id]) end
    end

    def check_user
      unless current_user?(params[:user_id])
        render status: 403, json: { message: 'User does not own device' }
      end
    end

end
