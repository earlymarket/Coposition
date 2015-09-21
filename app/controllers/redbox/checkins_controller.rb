class Redbox::CheckinsController < ApplicationController

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

  def create
    Checkin.create_from_string(request.body.read, add_device: true)
    render text: "ok"
  end

  def destroy
    Checkin.where(device: params[:id]).destroy_all
    redirect_to redbox_device_path
  end

  def spoof
  end

  def create_spoofs
    Checkin.transaction do
      params[:number_of_times].to_i.times do
        Checkin.create_from_string(RequestFixture.new(params[:imei]).w_gps, add_device: true)
      end
    end
    redirect_to redbox_devices_path
  end

end