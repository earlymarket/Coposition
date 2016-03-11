class Users::DevicesController < ApplicationController

  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session
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
    # Checkin.includes(:device).where(device_id: @device.id)
    @checkins = Checkin.joins(:device).where(device_id: @device.id).paginate(page: params[:page], per_page: 50).order('created_at DESC')
    gon.checkins = @checkins
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
    @redirect_target = params[:redirect] if params[:redirect]
  end

  def create
    @device = Device.new
    @device = Device.find_by uuid: allowed_params[:uuid] if allowed_params[:uuid].present?
    if @device
      if @device.user.nil?
        @device.construct(current_user, allowed_params[:name])
        @device.checkins.create(checkin_params) if params[:create_checkin].present?
        flash[:notice] = "This device has been bound to your account!"
        redirect_using_param_or_default unless via_app
      else
        invalid_payload('This device has already been assigned to a user', new_user_device_path)
      end
    else
      invalid_payload('The UUID provided does not match an existing device', new_user_device_path)
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
    def via_app
      render json: @device.to_json if req_from_coposition_app?
    end

    def allowed_params
      params.require(:device).permit(:uuid,:name)
    end

    def checkin_params
      { lat: params[:location].split(",").first, lng: params[:location].split(",").last }
    end

    def redirect_using_param_or_default(default: user_device_path(current_user.url_id, @device.id))
      if params[:redirect].blank?
        redirect_to default
      else
        redirect_to params[:redirect]
      end
    end

    def require_ownership
      unless user_owns_device?
        flash[:notice] = "You do not own that device"
        redirect_to root_path
      end
    end

end
