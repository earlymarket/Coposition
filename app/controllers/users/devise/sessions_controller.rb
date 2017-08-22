class Users::Devise::SessionsController < Devise::SessionsController
  protect_from_forgery with: :exception, unless: :req_from_coposition_app?
  skip_before_action :require_no_authentication, if: :req_from_coposition_app?
  respond_to :json

  def create
    req_from_coposition_app? ? respond_with_auth_token : super
  end

  def new
    session[:return_to] = params[:return_to]
    super
  end

  def destroy
    req_from_coposition_app? ? destroy_auth_token : super
  end

  private

  def verify_signed_out_user
    super unless req_from_coposition_app?
  end

  def respond_with_auth_token
    if params[:user]
      email = params[:user][:email]
      password = params[:user][:password]
    end

    return unless valid_request?(email, password)

    render status: 200, json: @user.public_info.as_json.merge(
      authentication_token: @user.authentication_token,
      access_token: @user.copo_app_access_token
    )
  end

  def destroy_auth_token
    user = User.find_by(authentication_token: request.headers["X-User-Token"])

    if user.nil?
      render status: 404, json: { error: "Invalid token." }
    else
      user.authentication_token = nil
      user.save!
      render status: 200, json: { message: "Signed out" }
    end
  end

  def valid_request?(email, password)
    if (@user = User.find_for_authentication(email: email)) && @user.valid_password?(password)
      @user
    else
      render status: 400, json: { error: "The request MUST contain the user email and password." }
      false
    end
  end

  def after_sign_in_path_for(resource)
    return session[:return_to] if session[:return_to]
    stored_location_for(resource) || user_dashboard_path(resource)
  end
end
