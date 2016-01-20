class Api::V1::UsersController < Api::ApiController
  respond_to :json

  before_action :authenticate
  before_action :check_user_approved_developer, except: [:index]

  def index
    respond_with User.all.select(:id, :username)
  end

  def show
    respond_with @user
  end

  def last_checkin
    checkin = @user.last_checkin
    device = Device.find(checkin.device_id)
    render json: [device, checkin]
  end

  def all_checkins
    checkins = @user.checkins.order('created_at DESC').paginate(page: params[:page])
    response['X-Current-Page'] = checkins.current_page.to_json
    response['X-Next-Page'] = checkins.next_page.to_json
    response['X-Total-Entries'] = checkins.total_entries.to_json
    response['X-Per-Page'] = checkins.per_page.to_json
    render json: checkins
  end

  def requests
    if params[:developer_id]
      requests = @user.requests.where(developer_id: params[:developer_id]).order('created_at DESC').paginate(page: params[:page])
    else
      requests = @user.requests.order('created_at DESC').paginate(page: params[:page])
    end
    requests_descriptions = []
    requests.each do |request|
      requests_descriptions << [request, request.description[request.controller.intern][request.action.intern]]
    end
    response['X-Current-Page'] = requests.current_page.to_json
    response['X-Next-Page'] = requests.next_page.to_json
    response['X-Total-Entries'] = requests.total_entries.to_json
    response['X-Per-Page'] = requests.per_page.to_json
    render json: requests_descriptions
  end

  def last_request
    request = @user.requests.last
    description = request.description[request.controller.intern][request.action.intern]
    render json: [request, description]
  end

end