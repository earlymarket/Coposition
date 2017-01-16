class Users::CheckinsController < ApplicationController
  protect_from_forgery except: :show
  before_action :authenticate_user!
  before_action :require_checkin_ownership, only: [:show, :update, :destroy]
  before_action :require_device_ownership, only: [:index, :new, :create, :destroy_all]

  def new
    @device = Device.find(params[:device_id])
    @checkin = Device.find(params[:device_id]).checkins.new
  end

  def index
    @device = Device.find(params[:device_id])
    per_page = params[:per_page].to_i <= 1000 ? params[:per_page] : 1000
    render json: {
      checkins: @device.checkins.paginate(page: params[:page], per_page: per_page)
        .select(:id, :lat, :lng, :created_at, :address, :fogged, :fogged_city, :device_id),
      current_user_id: current_user.id,
      total: @device.checkins.count
    }
  end

  def create
    @device = Device.find(params[:device_id])
    @checkin = @device.checkins.create(allowed_params)
    @device.notify_subscribers('new_checkin', @checkin)
    flash[:notice] = 'Checked in.'
  end

  def import
    if params[:file] && valid_file?
      Checkin.import(params[:file])
      flash[:notice] = 'Importing check-ins'
    else
      flash[:alert] = 'Invalid file'
    end
    redirect_to user_devices_path(current_user.url_id)
  end

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
  end

  def update
    @checkin = Checkin.find(params[:id])
    if params[:checkin]
      @checkin.update(allowed_params)
      @checkin.refresh
      return render status: 200, json: @checkin unless @checkin.errors.any?
      render status: 400, json: @checkin.errors.messages
    else
      @checkin.switch_fog
    end
  end

  def destroy
    @checkin = Checkin.find_by(id: params[:id]).delete
    flash[:notice] = 'Check-in deleted.'
  end

  def destroy_all
    Checkin.where(device: params[:device_id]).delete_all
    flash[:notice] = 'History deleted.'
    redirect_to user_device_path(current_user.url_id, params[:device_id])
  end

  private

  def allowed_params
    params.require(:checkin).permit(:lat, :lng, :device_id, :fogged)
  end

  def valid_file?
    CSV.foreach(params[:file].path, headers: true) do |csv|
      return csv.headers == Checkin.column_names
    end
  end

  def require_checkin_ownership
    return if user_owns_checkin?
    flash[:alert] = 'You do not own that check-in.'
    redirect_to root_path
  end

  def require_device_ownership
    return if current_user.devices.exists?(params[:device_id])
    flash[:alert] = 'You do not own this device.'
    redirect_to root_path
  end
end
