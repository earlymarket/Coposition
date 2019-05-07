class Api::ApiController < ActionController::API
  include ApiApplicationMixin
  rescue_from ::ActiveRecord::RecordNotFound, with: :render_404_and_error
  rescue_from ::ActionController::ParameterMissing, with: :render_400_and_error

  before_action :find_user, :authenticate, :update_last_mobile_visit_at

  private

  def find_user
    @user = if doorkeeper_token.present?
      User.active_users.find(doorkeeper_token.resource_owner_id)
    elsif params[:controller] == "api/v1/users"
      User.active_users.find(params[:id])
    else
      User.active_users.find(params[:user_id])
    end
  end

  def authenticate
    api_key = request.headers["X-Api-Key"]
    @dev = Developer.where(api_key: api_key).first if api_key
    if @dev
      create_request
    else
      render status: 401, json: { error: "No valid API Key" }
    end
  end

  def create_request
    if @user
      @dev.requests.create(user_id: @user.id, action: params[:action], controller: params[:controller])
    else
      @dev.requests.create(action: params[:action], controller: params[:controller])
    end
  end

  def check_user_approved_approvable
    @permissible = find_permissible
    return if req_from_coposition_app?

    if !@user.approved?(@dev)
      render status: 401, json: { error: "approval_status: #{@user.approval_for(@dev).status}" }
    elsif !@user.approved?(@permissible)
      render status: 401, json: { error: "approval_status: #{@user.approval_for(@permissible).status}" }
    end
  end

  def find_permissible
    params[:permissible_id] ? User.find(params[:permissible_id]) : @dev
  end

  def paginated_response_headers(resource)
    response["X-Current-Page"] = resource.current_page.to_json
    response["X-Next-Page"] = resource.next_page.to_json
    response["X-Total-Entries"] = resource.total_entries.to_json
    response["X-Per-Page"] = resource.per_page.to_json
  end

  def current_user?(user_id)
    auth_token = User.find(user_id).authentication_token
    request.headers["X-User-Token"] == auth_token
  end

  def resource_exists?(resource, arguments)
    model = resource.titleize.constantize
    render status: 404, json: { error: "#{model} does not exist" } unless arguments
    arguments
  end

  def render_404_and_error(exception)
    render status: 404, json: { error: exception.message }
  end

  def render_400_and_error(exception)
    render status: 400, json: { error: exception.message }
  end

  def update_last_mobile_visit_at
    @user.update_last_mobile_visit_at if req_from_coposition_app?
  end
end
