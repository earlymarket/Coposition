class Api::ApiController < ActionController::Base
  include ApiApplicationMixin
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :find_user, :authenticate

  private

  def find_user
    if params[:controller] == "api/v1/users"
      @user = User.find(params[:id])
    else
      @user = User.find(params[:user_id])
    end
  end

  def authenticate
    api_key = request.headers['X-Api-Key']
    @dev = Developer.where(api_key: api_key).first if api_key
    if @dev
      create_request
    else
      render status: 401, json: { message: 'No valid API Key' }
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
    if !@user.approved?(@dev)
      render status: 401, json: { "approval status": @user.approval_for(@dev).status }
    elsif !@user.approved?(@permissible)
      render status: 401, json: { "approval status": @user.approval_for(@permissible).status }
    end
  end

  def find_permissible
    params[:permissible_id] ? User.find(params[:permissible_id]) : @dev
  end

  def paginated_response_headers(resource)
    response['X-Current-Page'] = resource.current_page.to_json
    response['X-Next-Page'] = resource.next_page.to_json
    response['X-Total-Entries'] = resource.total_entries.to_json
    response['X-Per-Page'] = resource.per_page.to_json
  end

  def current_user?(user_id)
    auth_token = User.find(user_id).authentication_token
    request.headers['X-User-Token'] == auth_token
  end

  def resource_exists?(resource, arguments)
    model = resource.titleize.constantize
    render status: 404, json: { message: "#{model} does not exist" } unless arguments
    arguments
  end

  def record_not_found(exception)
    render json: {error: exception.message}.to_json, status: 404 and return
  end
end
