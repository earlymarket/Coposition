class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionView::MissingTemplate, with: :template_not_found
  include ApiApplicationMixin

  def template_not_found
    Rails.logger.warn "Redirect to 404, Error: ActionView::MissingTemplate"
    redirect_to root_path
  end

  def record_not_found(exception)
    redirect_to root_path, alert: exception.message
  end

  def approvals_presenter_and_gon(params)
    @approvals_presenter = Users::ApprovalsPresenter.new(current_user, params)
    gon.push(@approvals_presenter.gon)
  end

  def correct_url_user?
    return if User.find(params[:user_id].downcase) == current_user
    redirect_to controller: params[:controller], action: params[:action], user_id: current_user.friendly_id
  end

  def authenticate_admin!
    authenticate_user!

    redirect_to root_path, alert: "Unauthorized Access" unless current_user.admin?
  end

  def url_redirect
    return if current_user
    redirect_to(new_user_session_url(return_to: request.fullpath))
  end
end
