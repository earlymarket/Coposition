class Redbox::CheckinsController < ApplicationController

  protect_from_forgery except: :create

  def index
    @checkin_count = Checkin.count
  end

  def show
    render json: Checkin.find(params[:id]).to_json
  end

  def create
    Checkin.create_from_string(request.body.read, add_device: true)
    render text: "ok"
  end

end
