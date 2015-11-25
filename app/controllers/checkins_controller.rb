class CheckinsController < ApplicationController

  protect_from_forgery except: :create

  def index
    @checkin_count = Checkin.count
  end

  def show
    checkin = Checkin.find(params[:id])
    unless params[:range] 
      render json: checkin.to_json
    else
      # /2?range=3 returns IDs 2,3,4
      render json: Checkin.find_range(checkin.id, params[:range].to_i)
    end
  end

  def destroy
    Checkin.where(device: params[:id]).destroy_all if user_owns_device?
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.id, params[:id])
  end

end