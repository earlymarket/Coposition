class Api::ApiController < ActionController::Base


  private

  def authenticate
    api_key = request.headers['X-Api-Key']
    @dev = Developer.where(api_key: api_key).first if api_key
    unless @dev
      head status: :unauthorized
      return false
    end
    create_request
  end

  def create_request
    find_user if (params[:user_id] || params[:id])
    if @user
      @dev.requests.create(user_id: @user.id, action: params[:action], controller: params[:controller])
    else
      @dev.requests.create(action: params[:action], controller: params[:controller])
    end
  end

  def paginated_response_headers(resource)
    response['X-Current-Page'] = resource.current_page.to_json
    response['X-Next-Page'] = resource.next_page.to_json
    response['X-Total-Entries'] = resource.total_entries.to_json
    response['X-Per-Page'] = resource.per_page.to_json
  end

  def check_user_approved_developer
    find_user
    unless @user.approved_developer?(@dev)
      render json: { "approval status": @user.approval_status_for(@dev) }
    end
  end

  def find_user
    if params[:controller] == "api/v1/users"
      find_by_id(params[:id])
    else
      find_by_id(params[:user_id])
    end
  end

  def find_device
    if params[:device_id] then @device = Device.find(params[:device_id]) end
  end

  def find_owner
    @owner = @device || find_by_id(params[:user_id])
  end

  def model_find(type)
    [User, Developer].find { |model| model.name == type.titleize}
  end

  def check_privilege
    if @device
      unless @device.privilege_for(@dev) == "complete"
        head status: :unauthorized
        return false
      end
    end
  end

  def find_by_id(id)
    @user = User.find_by_username(id)
    @user ||= User.find_by_email(id)
    @user ||= User.find(id)
  end

  def current_user?(user_id)
    auth_token = User.find(user_id).authentication_token
    request.headers['X-User-Token'] == auth_token
  end

  def method_missing(method_sym, *arguments, &block)
    method_string = method_sym.to_s
    if /(?<resource>[\w]+)_exists\?$/ =~ method_string
      resource_exists?(resource, arguments[0])
    else
      super
    end
  end

  def resource_exists?(resource, arguments)
    model = resource.titleize.constantize
    render status: 404, json: { message: "#{model} does not exist" } unless arguments
    arguments
  end

  def req_from_coposition_app?
    @from_copo_app ||= request.headers["X-Secret-App-Key"] == Rails.application.secrets.mobile_app_key
  end
end
