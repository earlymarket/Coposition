class Users::CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_checkin_ownership, except: [:destroy_all]
  before_action :require_device_ownership, only: [:destroy_all]

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
  end

  def destroy
    respond_to do |format|
      @checkin_id = params[:id]
      Device.find(params[:device_id]).checkins.find(@checkin_id).delete
      flash[:notice] = "Check-in deleted."
      format.js
      format.html {redirect_to user_device_path(current_user.url_id, params[:device_id])}
    end
  end

  def destroy_all
    Checkin.where(device: params[:device_id]).destroy_all
    flash[:notice] = "History deleted."
    redirect_to user_device_path(current_user.url_id, params[:device_id])
  end

  private

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
