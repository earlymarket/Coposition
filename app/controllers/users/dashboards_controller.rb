class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    @presenter = ::Users::DashboardsPresenter.new(current_user)
    gon.push(@presenter.gon)
  end

end
