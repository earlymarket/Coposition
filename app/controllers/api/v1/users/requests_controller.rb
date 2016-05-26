class Api::V1::Users::RequestsController < Api::ApiController
  respond_to :json

  before_action :check_user_approved_approvable

  def index
    requests = if params[:developer_id]
                 @user.requests.where(developer_id: params[:developer_id]).paginate(page: params[:page])
               else
                 @user.requests.paginate(page: params[:page])
               end
    paginated_response_headers(requests)
    render json: requests
  end

  def last
    requests = if params[:developer_id] == @dev.id.to_s
                 # We use [-2] instead of .last because the last request will ironically be the one you're making
                 @user.requests.where(developer_id: params[:developer_id]).second
               elsif params[:developer_id]
                 # If we're checking someone else's last request, go ahead and show their last one
                 @user.requests.where(developer_id: params[:developer_id]).first
               else
                 @user.requests.second
               end
    render json: [requests]
  end
end
