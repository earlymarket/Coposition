class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    sleep 1
    flash[:notification] = current_user.notifications
  end

end
