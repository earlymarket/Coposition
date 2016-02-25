class Api::V1::Users::RequestsController < Api::ApiController
  respond_to :json

  before_action :authenticate, :check_user_approved_approvable

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
    if params[:developer_id] == @dev.id.to_s
      # We use [-2] instead of .last because the last request will ironically be the one you're making
      requests = @user.requests.where(developer_id: params[:developer_id])[-2]
    elsif params[:developer_id]
      # If we're checking someone else's last request, go ahead and show their last one
      requests = @user.requests.where(developer_id: params[:developer_id]).last
    else
      requests = @user.requests[-2]
    end
    render json: [requests]
  end

end
