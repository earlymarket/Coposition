class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApiApplicationMixin

  def invalid_payload(msg, redirect_path)
    flash[:alert] = msg
    redirect_to redirect_path
  end

end
