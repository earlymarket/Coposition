class Users::CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_checkin_ownership, except: [:new, :create, :destroy_all]
  before_action :require_device_ownership, only: [:new, :create, :destroy_all]

  def new
    @device = Device.find(params[:device_id])
    @checkin = Device.find(params[:device_id]).checkins.new
  end

  def create
    @device = Device.find(params[:device_id])
    @checkin = @device.checkins.create(allowed_params)
    flash[:notice] = "Checked in."
    respond_to do |format|
      format.html { redirect_to user_device_path(current_user.url_id, params[:device_id]) }
      format.js
    end
  end

  def show
    checkin = Checkin.find(params[:id])
    checkin.reverse_geocode!
    @checkin = checkin
  end

  def update
    @checkin = Checkin.find(params[:id])
    @checkin.switch_fog
    flash[:notice] = "Check-in fogging changed."
  end

  def destroy
    respond_to do |format|
      @checkin = Checkin.find_by(id: params[:id]).delete
      flash[:notice] = "Check-in deleted."
      format.js
      format.html {redirect_to user_device_path(current_user.url_id, params[:device_id])}
    end
  end

  def destroy_all
    Checkin.where(device: params[:device_id]).delete_all
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.url_id, params[:device_id])
  end

  private

    def allowed_params
      params.require(:checkin).permit(:lat, :lng, :device_id)
    end

    def require_checkin_ownership
      unless user_owns_checkin?
        flash[:alert] = "You do not own that check-in."
        redirect_to root_path
      end
    end

    def require_device_ownership
      unless current_user.devices.exists?(params[:device_id])
        flash[:alert] = "You do not own this device."
        redirect_to root_path
      end
    end

end
