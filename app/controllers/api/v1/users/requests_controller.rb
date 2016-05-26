class Api::V1::Users::RequestsController < Api::ApiController
  respond_to :json

  before_action :check_user_approved_approvable

  def index
    requests = if params[:developer_id]
                 @user.requests.where(developer_id: params[:developer_id])
               else
                 @user.requests
               end.paginate(page: params[:page])
    paginated_response_headers(requests)
    render json: requests
  end

  def last
    developer_id = params[:developer_id]
    requests = if developer_id == @dev.id.to_s
                 # We use [-2] instead of .last because the last request will ironically be the one you're making
                 @user.requests.where(developer_id: developer_id).second
               elsif developer_id
                 # If we're checking someone else's last request, go ahead and show their last one
                 @user.requests.where(developer_id: developer_id).first
               else
                 @user.requests.second
               end
    render json: [requests]
  end
end
