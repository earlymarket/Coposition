class Api::ApiController < ActionController::Base

  private
 
  def authenticate
    api_key = request.headers['X-Api-Key']
    @dev = Developer.where(api_key: api_key).first if api_key
    unless @dev
      head status: :unauthorized
      return false
    end
    Request.create(developer: @dev, 
                   user_id: params[:user_id],
                   action: params[:action],
                   controller: params[:controller])
  end

  def check_user_approved_developer
    find_user
    unless @user.approved_developer?(@dev)
      render json: { "approval status": @user.approval_status_for(@dev) }
    end
  end

  def find_user
    @user = User.find_by_username(params[:user_id])
    @user = User.find_by_email(params[:user_id]) unless @user
    @user = User.find(params[:user_id]) unless @user
  end

  def find_device
    @device = Device.find(params[:device_id])
  end
  
  def check_privilege
    unless @device.privilege_for(@dev) == "complete"
      head status: :unauthorized
      return false
    end
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

end
