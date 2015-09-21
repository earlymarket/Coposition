class Redbox::DevicesController < ApplicationController

  before_action :authenticate_user!

  def index
    @devices = current_user.devices
  end

  def show
    @device = Device.find(params[:id]) if user_owns_resource?
  end

  def new
    @device = Device.new
  end

  def create
    device = Device.find_by imei: allowed_params[:imei]
    if device
      # Providing that there isn't anyone currently assigned
      if device.user.nil?
        device.user = current_user
        device.name = allowed_params[:name]
        device.save
        flash[:notice] = "This device has been bound to your account!"
        redirect_to redbox_devices_path
      else
        flash[:alert] = "This device has already been assigned an account!"
        redirect_to new_redbox_device_path
      end
    else
      flash[:alert] = "Not found"
      redirect_to new_redbox_device_path
    end
  end

  def edit
    @device = Device.find(params[:id]) if user_owns_resource?
  end

  private
  def allowed_params
    params.require(:device).permit(:imei,:name)
  end

  def user_owns_resource?
    if params[:id]
      device = Device.find(params[:id])
      device.user == current_user if device
    end
  end

end
