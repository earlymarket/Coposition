class Users::DevicesController < ApplicationController

  before_action :authenticate_user!, except: :shared
  before_action :published?, only: :shared
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    gon.current_user_id = current_user.id
    @devices = current_user.devices.order(:id).includes(:developers, :permitted_users, :permissions).map do |dev|
      dev.checkins.first.reverse_geocode! if dev.checkins.exists?
      dev
    end
    gon.devices = @devices
    gon.permissions = @devices.map(&:permissions).inject(:+)
  end

  def show
    @device = Device.find(params[:id])
    @from, @to = date_range
    gon.checkins = @device.checkins.where(created_at: @from..@to).paginate(page: params[:page], per_page: 1000)
    flash[:notice] = "No checkins available" if gon.checkins.empty?
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
    user = device.user.as_json
    user['avatar'] = device.user.avatar.as_json({})
    gon.user = user
    gon.checkin = checkin.reverse_geocode! if checkin
  end

  def create
    @device = Device.new
    @device = Device.find_by uuid: allowed_params[:uuid] if allowed_params[:uuid].present?
    if @device
      if @device.user.nil?
        @device.construct(current_user, allowed_params[:name])
        gon.checkins = @device.checkins.create(checkin_params) if params[:create_checkin].present?
        redirect_to user_device_path(id: @device.id), notice: "This device has been bound to your account!"
      else
        redirect_to new_user_device_path, notice: 'This device has already been assigned to a user'
      end
    else
      redirect_to new_user_device_path, notice: 'The UUID provided does not match an existing device'
    end
  end

  def edit
    @device = Device.find(params[:id])
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
      flash[:notice] = "#{@device.name} timeshifted by #{@device.delayed.to_i} minutes."
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
      { lat: params[:location].split(",").first, lng: params[:location].split(",").last }
    end

    def require_ownership
      unless user_owns_device?
        flash[:notice] = "You do not own that device"
        redirect_to root_path
      end
    end

    def date_range
      if (params[:from].present?)
        return Date.parse(params[:from]).beginning_of_day, Date.parse(params[:to]).end_of_day
      elsif @device.checkins.present?
        most_recent = Date.parse(@device.checkins.first.created_at.to_s)
        return  (most_recent << 1).beginning_of_day, most_recent.end_of_day
      else return nil, nil
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
