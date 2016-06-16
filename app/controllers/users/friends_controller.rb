class Users::FriendsController < ApplicationController
  before_action :friends?

  def show
    @friend = User.find(params[:id]).public_info
    @devices = @friend.devices.includes(:checkins)
    gon.checkins = @devices.map do |device|
      checkins = device.safe_checkin_info_for(permissible: current_user)
      checkins.first.as_json.merge(device: device.name) if checkins.present?
    end.compact
  end

  def show_device
    friend = User.find(params[:id])
    device = friend.devices.find(params[:device_id])
    checkins = friend.get_checkins(current_user, device)
    checkins.replace_foggable_attributes unless device.can_bypass_fogging?(current_user)
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
