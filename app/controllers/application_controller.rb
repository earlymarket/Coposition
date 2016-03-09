class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApiApplicationMixin

  def invalid_payload(msg, redirect_path)
    if req_from_coposition_app?
      render status: 400, json: { message: msg }
    else
      flash[:alert] = msg
      redirect_to redirect_path
    end
  end

  def current_user?(user_id)
    current_user == User.find(user_id)
  end

end