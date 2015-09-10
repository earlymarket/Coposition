class Redbox::CheckinsController < ApplicationController

  def index
    @checkin_count = Checkin.count
  end

  def show
    render json: Checkin.find(params[:id]).to_json
  end

end
