class Api::V1::Users::CheckinsController < Api::ApiController
  respond_to :json

  before_action :check_user_approved_approvable, :find_device

  def index
    params[:per_page].to_i <= 1000 ? per_page = params[:per_page] : per_page = 1000
    checkins = @user.get_checkins(@permissible, @device).order(created_at: :desc) \
      .paginate(page: params[:page], per_page: per_page)
    paginated_response_headers(checkins)
    checkins = checkins.map do |checkin|
      checkin.resolve_address(@permissible, params[:type])
    end
    render json: checkins
  end

  def last
    checkin = @user.get_checkins(@permissible, @device).order(created_at: :desc).first
    checkin = checkin.resolve_address(@permissible, params[:type]) if checkin
    if checkin
      render json: [checkin]
    else
      render json: []
    end
  end

  private

    def find_device
      if params[:device_id] then @device = Device.find(params[:device_id]) end
    end

end
