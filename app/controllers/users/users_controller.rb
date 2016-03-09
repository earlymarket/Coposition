class Users::UsersController < ApplicationController

  def show
    redirect_to action: "show", controller: "users/dashboards", user_id: params[:id]
  end

end
