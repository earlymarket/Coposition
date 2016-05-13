class Users::FriendsController < ApplicationController
  before_action :friends?

  def show
    @friend = User.find(params[:id])
    @devices = @friend.devices.includes(:checkins)
    checkins = @friend.get_user_checkins_for(current_user)
    gon.checkins = checkins.calendar_data if checkins.exists?
  end

  def show_device
    @friend = User.find(params[:id])
    @device = @friend.devices.find(params[:device_id])
    gon.checkins = @friend.get_checkins(current_user, @device)
    gon.checkins.get_data unless @device.can_bypass_fogging?(current_user)
  end

  private
    def friends?
      friend = User.find(params[:id])
      unless friend.approved?(current_user)
        flash[:notice] = 'You are not friends with that user'
        redirect_to user_friends_path(current_user)
      end
    end
end
