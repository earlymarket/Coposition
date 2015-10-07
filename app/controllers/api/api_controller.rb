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
    find_user
    unless @user.approved_developer?(@dev)
      render json: { "approval status": @user.approval_status_for(@dev) }
    end
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def find_device
    @device = Device.find(params[:device_id])
  end
end
