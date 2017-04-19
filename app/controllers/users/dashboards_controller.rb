class Users::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_url_user?

  def show
    @dashboard_presenter = ::Users::DashboardsPresenter.new(current_user)
    gon.push(@dashboard_presenter.gon)
  end
end
