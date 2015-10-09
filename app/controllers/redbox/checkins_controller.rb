class Redbox::CheckinsController < ApplicationController

  protect_from_forgery except: :create

  def index
    @checkin_count = RedboxCheckin.count
  end

  def show
    checkin = RedboxCheckin.find(params[:id])
    unless params[:range] 
      render json: checkin.to_json
    else
      # /2?range=3 returns IDs 2,3,4
      render json: RedboxCheckin.find_range(checkin.id, params[:range].to_i)
    end
  end

  def create
    RedboxCheckin.create_from_string(request.body.read)
    render text: "ok"
  end

  def destroy
    RedboxCheckin.where(device: params[:id]).destroy_all
    redirect_to user_device_path(current_user.id)
  end

  def spoof
  end

  def create_spoofs
    RedboxCheckin.transaction do
      params[:number_of_times].to_i.times do
        RedboxCheckin.create_from_string(RequestFixture.new(params[:uuid]).w_gps)
      end
    end
    redirect_to user_devices_path(current_user)
  end

end