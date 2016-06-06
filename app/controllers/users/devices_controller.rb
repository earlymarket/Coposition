class Users::DevicesController < ApplicationController
  before_action :authenticate_user!, except: :shared
  before_action :published?, only: :shared
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'index')
    gon.push(@presenter.gon)
    @presenter.devices.geocode_last_checkins
  end

  def show
    @presenter = ::Users::DevicesPresenter.new(current_user, params, 'show')
    gon.push(@presenter.show_gon)
    respond_to do |format|
      format.html { flash[:notice] = 'Right click on the map to checkin' }
      format.csv { send_data @presenter.checkins, filename: @presenter.filename }
    end
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def shared
    device = Device.find(params[:id])
    checkin = device.checkins.first
    gon.device = device.public_info
    gon.user = device.user.public_info_hash
    gon.checkin = checkin.reverse_geocode!.replace_foggable_attributes.public_info if checkin
  end

  def create
    @device = Device.new
    @device = Device.find_by uuid: allowed_params[:uuid] if allowed_params[:uuid].present?
    if @device && @device.user.nil?
      if @device.construct(current_user, allowed_params[:name])
        gon.checkins = @device.checkins.create(checkin_params) if params[:create_checkin].present?
        @device.notify_subscribers('new_device', @device)
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
    flash[:notice] = 'Device deleted'
    redirect_to user_devices_path
  end

  def update
    @device = Device.find(params[:id])
    if params[:delayed]
      @device.update_delay(params[:delayed])
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
    params.require(:device).permit(:uuid, :name, :delayed)
  end

  def checkin_params
    { lng: params[:location].split(',').first, lat: params[:location].split(',').last }
  end

  def require_ownership
    return if user_owns_device?
    flash[:notice] = 'You do not own that device'
    redirect_to root_path
  end

  def published?
    redirect_to root_path, notice: 'Device is not shared' unless Device.find(params[:id]).published?
  end

  def boolean_to_state(boolean)
    boolean ? 'on' : 'off'
  end
end
