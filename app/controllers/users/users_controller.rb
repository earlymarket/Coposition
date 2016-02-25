class Users::UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

end