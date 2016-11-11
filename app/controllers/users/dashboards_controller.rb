class Users::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_url_user?

  def show
    @presenter = ::Users::DashboardsPresenter.new(current_user)
    gon.push(@presenter.gon)
  end
end
