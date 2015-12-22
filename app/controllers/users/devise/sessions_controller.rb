class Users::Devise::SessionsController < Devise::SessionsController

  respond_to :json

  protect_from_forgery with: :null_session

  def create
    req_from_coposition_app? ? respond_with_auth_token : super
  end

  def destroy
    req_from_coposition_app? ? destroy_auth_token : super
  end

  private

    def verify_signed_out_user
      super unless req_from_coposition_app?
    end

    def respond_with_auth_token
      @email = params[:user][:email] if params[:user]
      @password = params[:user][:password] if params[:user]

      # Validations
      return unless valid_request?

      user = User.find_by(email: @email)
      if user && user.valid_password?(@password)
        user.restore_authentication_token!
        render status: 200, json: { 
          email: user.email, 
          authentication_token: user.authentication_token
        }
      else
        render status: 401, json: { message: 'Invalid email or password.' }
      end
    end

    def destroy_auth_token
      user = User.find_by(authentication_token: request.headers["X-User-Token"])

      if user.nil?
        render status: 404, json: { message: 'Invalid token.' }
      else
        user.authentication_token = nil
        user.save!
        render status: 204, json: nil
      end
    end

    def valid_request?
      if @email.nil? or @password.nil?
        render status: 400, json: { message: 'The request MUST contain the user email and password.' }
        return false
      end
      true
    end

end
