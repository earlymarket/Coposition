class Api::V1::UsersController < Api::ApiController
  respond_to :json

  before_action :authenticate

  def index
    respond_with User.all.select(:id, :username)
  end

  def show
    @user = User.find(params[:id])
    respond_with @user if @user.approved_developer?(@dev)
  end

  def last_checkin
    user = User.find(params[:id])
    device = user.last_used_device
    checkin = user.last_checkin
    respond_with [device, checkin] if user.approved_developer?(@dev)
  end

  def all_checkins
    user = User.find(params[:id])
    checkins = user.checkins.order('created_at DESC').paginate()
    render json: checkins
  end

  def requests
    user = User.find(params[:id])
    if params[:developer_id]
      requests = user.requests.where(developer_id: params[:developer_id]).order('created_at DESC').paginate()
    else
      requests = user.requests.order('created_at DESC').paginate()
    end
    desc = ""
    requests.each do |request|
      desc = request.description[request.controller.intern][request.action.intern]
    end
    render json: [requests, desc]
  end

  def last_request
    user = User.find(params[:id])
    request = user.requests.last
    description = request.description[request.controller.intern][request.action.intern]
    render json: [request, description]
  end

end