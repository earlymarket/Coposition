class Users::CheckinsController < ApplicationController
  before_action :authenticate_user!, :user_owns_checkin?

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
  end

  def destroy
    Checkin.where(device: params[:device_id]).destroy_all
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.id, params[:device_id])
  end

end