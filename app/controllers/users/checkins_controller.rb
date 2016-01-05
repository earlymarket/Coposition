class Users::CheckinsController < ApplicationController
  before_action :authenticate_user!, :user_owns_checkin?

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
  end

  def destroy
    Checkin.where(device: params[:device_id]).destroy_all if user_owns_device?
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.id, params[:id])
  end

  def user_owns_checkin?
    checkin_owner = Checkin.find(params[:id]).device.user
    if checkin_owner != current_user
      flash[:notice] = "Not authorised"
      redirect_to root_path
    end
  end
end