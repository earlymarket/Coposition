class Api::V1::Users::EmailRequestsController < Api::ApiController
  respond_to :json

  acts_as_token_authentication_handler_for User

  def index
    render json: @user.email_requests
  end

  def destroy
    EmailRequest.find(params[:id]).destroy
    render status: 200, json: { message: "Email request destroyed" }
  end
end
