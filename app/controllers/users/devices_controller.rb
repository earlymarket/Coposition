class Users::DevicesController < ApplicationController

  before_action :authenticate_user!
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    @current_user_id = current_user.id
    @devices = current_user.devices.map do |dev|
      dev.checkins.last.reverse_geocode! if dev.checkins.exists?
      dev
    end
  end

  def show
    @device = Device.find(params[:id])
    @checkins = Checkin.includes(:device) \
      .where(device_id: @device.id) \
      .order('created_at DESC') \
      .paginate(page: params[:page], per_page: 50)
    gon.checkins = @checkins
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def create
    @device = Device.new
    @device = Device.find_by uuid: allowed_params[:uuid] if allowed_params[:uuid].present?
    if @device
      if @device.user.nil?
        @device.construct(current_user, allowed_params[:name])
        @device.checkins.create(checkin_params) if params[:create_checkin].present?
        redirect_to user_device_path(id: @device.id), notice: "This device has been bound to your account!"
      else
        redirect_to new_user_device_path, notice: 'This device has already been assigned to a user'
      end
    else
      redirect_to new_user_device_path, notice: 'The UUID provided does not match an existing device'
    end
  end

  def destroy
    Checkin.where(device: params[:id]).delete_all
    Device.find(params[:id]).destroy
    flash[:notice] = "Device deleted"
    redirect_to user_devices_path
  end

  def update
    @device = Device.find(params[:id])
    if params[:mins]
      @device.set_delay(params[:mins])
      flash[:notice] = "#{@device.name} timeshifted by #{@device.delayed.to_i} minutes."
    else
      @device.switch_fog
      flash[:notice] = "#{@device.name} fogging has been changed."
    end
  end

  private

    def allowed_params
      params.require(:device).permit(:uuid,:name)
    end

    def checkin_params
      { lat: params[:location].split(",").first, lng: params[:location].split(",").last }
    end

    def require_ownership
      unless user_owns_device?
        flash[:notice] = "You do not own that device"
        redirect_to root_path
      end
    end

end
