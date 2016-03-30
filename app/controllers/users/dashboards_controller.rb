class Users::DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    # flash[:notification] = current_user.notifications
  end

end
