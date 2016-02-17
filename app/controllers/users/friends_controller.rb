class Users::FriendsController < ApplicationController
  def show
    @friend = current_user.friends.find(params[:id])
    @devices = @friend.devices
  end
end
