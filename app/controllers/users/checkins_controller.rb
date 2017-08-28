class Users::CheckinsController < ApplicationController
  protect_from_forgery except: :show

  before_action :authenticate_user!

  before_action :require_checkin_ownership, only: %i(show update destroy)
  before_action :require_device_ownership, only: %i(index new create destroy_all)
  before_action :find_checkin, only: %i(show update destroy)

  def new
    @checkin = device.checkins.new
  end

  def index
    checkins_presenter = ::Users::CheckinsPresenter.new(current_user, params)
    render json: checkins_presenter.json
  end

  def create
    checkin = device.checkins.create(allowed_params)
    if checkin.save
      @checkin = ActiveRecord::Base.connection.execute(Checkin.where(id: checkin).to_sql).first
      NotifyAboutCheckin.call(device: device, checkin: @checkin)
      flash[:notice] = "Checked in."
    else
      flash[:alert] = "Invalid latitude/longitude."
    end
  end

  def import
    result = Users::Checkins::ImportCheckins.call(params: params)
    if result.success?
      flash[:notice] = "Importing check-ins"
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
    render status: 200, json: @checkin if params[:checkin]
  end

  def destroy
    @checkin.destroy
    NotifyAboutDestroyCheckin.call(device: device, checkin: @checkin)
    flash[:notice] = "Check-in deleted."
  end

  def destroy_all
    checkins = device.checkins
    checkins = checkins.where(created_at: date_range) if params[:from]
    checkins.destroy_all
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.url_id, device.id)
  end

  private

  def device
    @device ||= Device.find(params[:device_id])
  end

  def date_range
    Date.parse(params[:from])..Date.parse(params[:to]).end_of_day
  end

  def allowed_params
    params.require(:checkin).permit(:lat, :lng, :device_id, :fogged, :speed, :altitude)
  end

  def find_checkin
    @checkin = Checkin.find(params[:id])
  end

  def require_checkin_ownership
    return if user_owns_checkin?

    flash[:alert] = "You do not own that check-in."
    redirect_to root_path
  end

  def require_device_ownership
    return if current_user.devices.exists?(params[:device_id])

    flash[:alert] = "You do not own this device."
    redirect_to root_path
  end
end
