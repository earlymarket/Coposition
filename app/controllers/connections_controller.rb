class ConnectionsController < ApplicationController

  def index
  end

  def show
    @checkin = Checkin.find(params[:id]).to_json
  end

  def new
  end

  def create
    checkin = Checkin.find_by imei: allowed_params
    if checkin
      # bind account
      flash[:notice] = "This device has been bound to your account!"
      redirect_to connection_path(checkin)
    else
      flash[:alert] = "Not found"
      redirect_to new_connection_path
    end
  end

  private
  def allowed_params
    params.require(:imei)
  end
end
