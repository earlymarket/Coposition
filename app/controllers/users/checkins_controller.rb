class Users::CheckinsController < ApplicationController
  protect_from_forgery except: :show

  before_action :authenticate_user!
  before_action :require_checkin_ownership, only: [:show, :update, :destroy]
  before_action :require_device_ownership, only: [:index, :new, :create, :destroy_all]
  before_action :find_checkin, only: [:show, :update, :destroy]

  def new
    @checkin = device.checkins.new
  end

  def index
    per_page = params[:per_page].to_i <= 1000 ? params[:per_page] : 1000
    render json: {
      checkins: device
        .checkins
        .paginate(page: params[:page], per_page: per_page)
        .select(:id, :lat, :lng, :created_at, :address, :fogged, :fogged_city, :device_id),
      current_user_id: current_user.id,
      total: device.checkins.count
    }
  end

  def create
    @checkin = device.checkins.create(allowed_params)
    NotifyAboutCheckin.call(device: device, checkin: @checkin)
    flash[:notice] = 'Checked in.'
  end

  def import
    result = Users::Checkins::ImportCheckins.new(params)
    if result.success?
      flash[:notice] = 'Importing check-ins'
    else
      flash[:alert] = result.error
    end
    redirect_to user_devices_path(current_user.url_id)
  end

  def show
    @checkin.reverse_geocode!
  end

  def update
    result = Users::Checkins::UpdateCheckin.call(params: params)
    @checkin = result.checkin
    if result.success?
      render status: 200, json: @checkin if params[:checkin]
    else
      render status: 400, json: @checkin.errors
    end
  end

  def destroy
    @checkin.delete
    NotifyAboutDestroyCheckin.call(device: device, checkin: @checkin)
    flash[:notice] = 'Check-in deleted.'
  end

  def destroy_all
    Checkin.where(device: params[:device_id]).delete_all
    flash[:notice] = 'History deleted.'
    redirect_to user_device_path(current_user.url_id, params[:device_id])
  end

  private

  def device
    @device ||= Device.find(params[:device_id])
  end

  def allowed_params
    params.require(:checkin).permit(:lat, :lng, :device_id, :fogged)
  end

  def find_checkin
    @checkin = Checkin.find(params[:id])
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
