class Api::V1::Users::RequestsController < Api::ApiController
  respond_to :json

  before_action :authenticate
  before_action :check_user_approved_developer

  def index
    if params[:developer_id]
      requests = @user.requests.where(developer_id: params[:developer_id]).order('created_at DESC').paginate(page: params[:page])
    else
      requests = @user.requests.order('created_at DESC').paginate(page: params[:page])
    end
    paginated_response_headers(requests)
    render json: requests
  end

  def last
    if params[:developer_id]
      requests = @user.requests.where(developer_id: params[:developer_id])[-2]
    else
      requests = @user.requests[-2]
    end
    render json: requests
  end

end
