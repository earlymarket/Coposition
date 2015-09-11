class Redbox::CheckinsController < ApplicationController

  def index
    @checkin_count = Checkin.count
  end

  def show
    render json: Checkin.find(params[:id]).to_json
  end

  def create
     Checkin.create_from_string(params["data"])
  end

  def allowed_params
    params.require(:data)
  end

end
