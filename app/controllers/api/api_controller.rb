class Api::ApiController < ActionController::Base
  
  private
 
  def authenticate
    api_key = request.headers['X-Api-Key']
    @dev = Developer.where(api_key: api_key).first if api_key
   
    unless @dev
      head status: :unauthorized
      return false
    end
  end

  def check_user_approved_developer
    @user = User.find(params[:user_id])
    @user.approved_developer?(@dev)
  end
end
