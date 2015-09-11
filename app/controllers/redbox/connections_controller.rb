class Redbox::ConnectionsController < ApplicationController

  def index
  end

  def show
    @checkin = Checkin.find(params[:id]).to_json
  end

  def new
  end

  def create
    device = Device.find_by imei: allowed_params
    if device
      unless !device.user.nil?
        device.user = current_user
      else
        flash[:alert] = "This device has already been assigned an account!"
      end
      flash[:notice] = "This device has been bound to your account!" unless flash[:alert]
      redirect_to redbox_connection_path(checkin)
    else
      flash[:alert] = "Not found"
      redirect_to new_redbox_connection_path
    end
  end

  private
  def allowed_params
    params.require(:imei)
  end
end
