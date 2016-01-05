class CheckinsController < ApplicationController

  protect_from_forgery except: :create

  def index
    @checkin_count = Checkin.count
  end

  def destroy
    Checkin.where(device: params[:id]).destroy_all if user_owns_device?
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.id, params[:id])
  end

end