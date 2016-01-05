class CheckinsController < ApplicationController

  protect_from_forgery except: :create

  def index
    @checkin_count = Checkin.count
  end

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
    @checkin.get_data
    render @checkin
  end

  def destroy
    Checkin.where(device: params[:id]).destroy_all if user_owns_device?
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.id, params[:id])
  end

end