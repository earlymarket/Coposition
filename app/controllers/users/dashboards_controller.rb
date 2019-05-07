class Users::DashboardsController < ApplicationController
  before_action :authenticate_user!, :update_user_last_web_visit_at, :correct_url_user?

  def show
    @dashboard_presenter = ::Users::DashboardsPresenter.new(current_user)
    gon.push(@dashboard_presenter.gon)
  end
end
