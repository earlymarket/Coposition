class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    @presenter = ::Users::DashboardPresenter.new(current_user.checkins)
    gon.weeks_checkins = @presenter.weeks_checkins
  end

end
