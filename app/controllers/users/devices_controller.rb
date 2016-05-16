class Users::DevicesController < ApplicationController

  before_action :authenticate_user!, except: :shared
  before_action :published?, only: :shared
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    @devices = current_user.devices.order(:id).includes(:developers, :permitted_users, :permissions)
    @devices.each { |device| device.checkins.first.reverse_geocode! if device.checkins.exists? }
    gon.checkins = current_user.checkins.calendar_data if current_user.checkins.exists?
    gon.current_user_id = current_user.id
    gon.devices = @devices
    gon.permissions = @devices.map(&:permissions).inject(:+)
  end

  def show
    @device = Device.find(params[:id])
    gon.checkins = @device.checkins
    flash[:notice] = "Right click on the map to checkin"
    gon.current_user_id = current_user.id
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def shared
    device = Device.find(params[:id])
    checkin = device.checkins.first
    gon.device = device
    gon.user = device.user.public_info_hash
    gon.checkin = checkin.reverse_geocode!.replace_foggable_attributes.public_info if checkin
  end

  def create
    @device = Device.new
    @device = Device.find_by uuid: allowed_params[:uuid] if allowed_params[:uuid].present?
    if @device && @device.user.nil?
      if @device.construct(current_user, allowed_params[:name])
        gon.checkins = @device.checkins.create(checkin_params) if params[:create_checkin].present?
        redirect_to user_device_path(id: @device.id)
      else
        redirect_to new_user_device_path, notice: "You already have a device with the name #{allowed_params[:name]}"
      end
    else
      redirect_to new_user_device_path, notice: 'Invalid UUID provided'
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
    if params[:delayed]
      @device.set_delay(params[:delayed])
      flash[:notice] = @device.humanize_delay
    elsif params[:published]
      @device.update(published: !@device.published)
      flash[:notice] = "Location sharing is #{boolean_to_state(@device.published)}."
    else
      @device.switch_fog
      flash[:notice] = "Location fogging is #{boolean_to_state(@device.fogged)}."
    end
  end

  private

    def allowed_params
      params.require(:device).permit(:uuid,:name,:delayed)
    end

    def checkin_params
      { lng: params[:location].split(",").first, lat: params[:location].split(",").last }
    end

    def require_ownership
      unless user_owns_device?
        flash[:notice] = "You do not own that device"
        redirect_to root_path
      end
    end

    def published?
      unless Device.find(params[:id]).published?
        redirect_to root_path, notice: "Device is not shared"
      end
    end

    def boolean_to_state(boolean)
      boolean ? "on" : "off"
    end

end
