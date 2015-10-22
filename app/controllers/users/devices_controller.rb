class Users::DevicesController < ApplicationController

  before_action :authenticate_user!

  def index
    @devices = current_user.devices.map do |dev|
    	dev.checkins.last.reverse_geocode!
    	dev
    end
  end

  def show
    @device = Device.find(params[:id]) if user_owns_device?
  end

  def new
    @device = Device.new
    @redirect_target = params[:redirect] if params[:redirect]
  end

  def create
    device = Device.find_by uuid: allowed_params[:uuid]
    if device
      # Providing that there isn't anyone currently assigned
      if device.user.nil?
        device.user = current_user
        device.name = allowed_params[:name]
        device.developers << current_user.approved_developers.map do |app|
          app.developer
        end
        device.save
        flash[:notice] = "This device has been bound to your account!"
        if params[:redirect].blank?
          redirect_to user_device_path(current_user.id, device.id)
        else
          redirect_to params[:redirect]
        end
      else
        flash[:alert] = "This device has already been assigned an account!"
        redirect_to new_user_device_path
      end
    else
      flash[:alert] = "Not found"
      redirect_to new_user_device_path
    end
  end

  def edit
    @device = Device.find(params[:id]) if user_owns_device?
    redirect_to user_devices_path
  end

  def destroy
    Device.find(params[:id]).destroy if user_owns_device?
    flash[:notice] = "Device deleted"
    redirect_to user_devices_path
  end

  def switch_privilige_for_developer
    binding.pry
    @device = Device.find(params[:id]) if user_owns_device?
    @device.change_privilege_for(params[:developer], @device.reverse_privilege_for(@developer))
  end

  private
  def allowed_params
    params.require(:device).permit(:uuid,:name)
  end

end
