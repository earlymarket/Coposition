class Users::FriendsController < ApplicationController
  before_action :friends?

  def show
    @friend = User.find(params[:id])
    @devices = @friend.devices.ordered_by_checkins.paginate(page: params[:page], per_page: 5)
    checkins = @friend.get_user_checkins_for(current_user)
    gon.checkins = checkins.calendar_data if checkins.exists?
  end

  def show_device
    friend = User.find(params[:id])
    device = friend.devices.find(params[:device_id])
    checkins = friend.get_checkins(current_user, device)
    checkins = checkins.replace_foggable_attributes unless device.can_bypass_fogging?(current_user)
    gon.checkins = checkins.map(&:public_info)
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
