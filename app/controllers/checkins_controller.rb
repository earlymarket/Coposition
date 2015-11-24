class CheckinsController < ApplicationController

  protect_from_forgery except: :create

  # Using @@model so Redbox::CheckinsController has access to same method
  @@model = Checkin

  def index
    @checkin_count = @@model.count
  end

  def show
    checkin = @@model.find(params[:id])
    unless params[:range] 
      render json: checkin.to_json
    else
      # /2?range=3 returns IDs 2,3,4
      render json: @@model.find_range(checkin.id, params[:range].to_i)
    end
  end

  def destroy
    @@model.where(device: params[:id]).destroy_all if user_owns_device?
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.id, params[:id])
  end

end