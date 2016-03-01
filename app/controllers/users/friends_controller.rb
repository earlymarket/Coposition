class Users::FriendsController < ApplicationController
  def show
    @friend = current_user.friends.find(params[:id])
    @devices = @friend.devices
  end

  def show_device
    @friend = current_user.friends.find(params[:id])
    @device = @friend.devices.find(params[:device_id])
    @checkins = @friend.get_checkins(current_user, @device).order('created_at DESC') \
      .paginate(page: params[:page], per_page: 50)
  end

  def show_checkin
    friend = current_user.friends.find(params[:id])
    @checkin = friend.checkins.find(params[:checkin_id])
    @fogged = @checkin.resolve_address(current_user, 'address')
  end
end
