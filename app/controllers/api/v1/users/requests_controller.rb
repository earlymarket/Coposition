class Api::V1::Users::RequestsController < Api::ApiController
  respond_to :json

  before_action :check_user_approved_approvable
  before_action -> { doorkeeper_authorize! :public }, unless: :req_from_coposition_app?

  def index
    requests = @user.requests.where(developer: @dev).paginate(page: params[:page])
    paginated_response_headers(requests)
    render json: requests
  end

  def last
    request = @user.requests.where(developer: @dev).second
    render json: [request]
  end
end
