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

end
