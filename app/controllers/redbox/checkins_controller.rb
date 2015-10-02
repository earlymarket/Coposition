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
    RedboxCheckin.create_from_string(request.body.read, add_device: true)
    render text: "ok"
  end

  def destroy
    RedboxCheckin.where(device: params[:id]).destroy_all
    redirect_to redbox_device_path
  end

  def spoof
  end

  def create_spoofs
    RedboxCheckin.transaction do
      params[:number_of_times].to_i.times do
        RedboxCheckin.create_from_string(RequestFixture.new(params[:imei]).w_gps, add_device: true)
      end
    end
    redirect_to redbox_devices_path
  end

end