class Users::DevicesController < ApplicationController

  before_action :authenticate_user!, except: :publish
  before_action :published?, only: :publish
  before_action :require_ownership, only: [:show, :destroy, :update]

  def index
    gon.current_user_id = current_user.id
    @devices = current_user.devices.includes(:developers, :permitted_users, :permissions).map do |dev|
      dev.checkins.last.reverse_geocode! if dev.checkins.exists?
      dev
    end
    gon.permissions = @devices.map(&:permissions).inject(:+)
  end

  def show
    @device = Device.find(params[:id])
    @from, @to = date_range
    @checkins = Checkin.where(device_id: @device.id, created_at: @from..@to)
    if @checkins.empty?
      flash[:notice] = "Showing last month's checkins if available"
      @checkins = Checkin.where(device_id: @device.id, created_at: 1.month.ago.beginning_of_day..Date.today.end_of_day)
    end
    @checkins = @checkins.order('created_at DESC').paginate(page: params[:page], per_page: 1000)
    gon.checkins = @checkins
    gon.chart_checkins = [];
    gon.chart_checkins = @checkins.group_for_chart(@checkins.last.created_at, @checkins.first.created_at) unless @checkins.empty?
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
  end

  def publish
    @device = Device.find(params[:id])
    @checkin = @device.checkins.last
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
    elsif params[:published]
      @device.update(published: !@device.published) unless @device.checkins.empty?
      flash[:notice] = "Location publishing is #{boolean_to_state(@device.published)}."
    else
      @device.switch_fog
      flash[:notice] = "Location fogging is #{boolean_to_state(@device.fogged)}."
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

    def date_range
      if (params[:from].present?)
        return Date.parse(params[:from]).beginning_of_day, Date.parse(params[:to]).end_of_day
      else
        return 1.month.ago.beginning_of_day, Date.today.end_of_day
      end
    end

    def published?
      unless Device.find(params[:id]).published?
        redirect_to root_path, notice: "Device is not published"
      end
    end

    def boolean_to_state(boolean)
      boolean ? "on" : "off"
    end

end
