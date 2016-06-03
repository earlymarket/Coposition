class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found
  include ApiApplicationMixin

  def record_not_found(exception)
    redirect_to root_path, alert: exception.message
  end

  def presenter_and_gon(type)
    @presenter = ::Users::ApprovalsPresenter.new(current_user, type)
    gon.push(@presenter.gon)
  end

  def zapier_data(approval)
    [current_user.public_info, approval]
  end
end
