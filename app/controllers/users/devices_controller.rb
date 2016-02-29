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
    @checkins = @device.checkins.order('created_at DESC').paginate(page: params[:page], per_page: 50)
  end

  def new
    @device = Device.new
    @device.uuid = params[:uuid] if params[:uuid]
    @adding_current_device = true if params[:curr_device]
    @redirect_target = params[:redirect] if params[:redirect]
  end

  def create
    if allowed_params[:uuid].present?
      @device = Device.find_by uuid: allowed_params[:uuid]
    else
      @device = Device.create
    end
    if @device
      if @device.user.nil?
        create_device
        redirect_using_param_or_default unless via_app
      else
        invalid_payload('This device has already been assigned to a user', new_user_device_path)
      end
    else
      invalid_payload('The UUID provided does not match an existing device', new_user_device_path)
    end
  end

  def destroy
    Device.find(params[:id]).destroy
    flash[:notice] = "Device deleted"
    redirect_to user_devices_path
  end

  def update
    @device = Device.find(params[:id])
    if params[:mins]
      set_delay
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

    def create_device
      @device.user = current_user
      @device.name = allowed_params[:name]
      @device.developers << current_user.developers
      @device.permitted_users << current_user.friends
      @device.save
      flash[:notice] = "This device has been bound to your account!"

      @device.checkins.create(lat: params[:location].split(",").first,
          lng: params[:location].split(",").last) unless params[:create_checkin].blank?
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

    def set_delay
      if params[:mins] == "0" || params[:mins] == ""
        @device.update(delayed: nil)
        flash[:notice] = "#{@device.name} is not timeshifted."
      else
        @device.update(delayed: params[:mins])
        flash[:notice] = "#{@device.name} is now timeshifted by #{@device.delayed} minutes."
      end
    end

end
