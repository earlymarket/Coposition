class Users::CheckinsController < ApplicationController
  before_action :authenticate_user!, :require_ownership

  def show
    @checkin = Checkin.find(params[:id])
    @checkin.reverse_geocode!
  end

  def destroy
    respond_to do |format|

      if params[:id]
        @checkin_id = params[:id]
        Device.find(params[:device_id]).checkins.find(@checkin_id).delete
        flash[:notice] = "Check-in deleted."
        format.js
      else
        Checkin.where(device: params[:device_id]).destroy_all
        flash[:notice] = "History deleted."
        format.html { redirect_to user_device_path(current_user.url_id, params[:device_id]) }
      end

    end
  end

  private
    def require_ownership
      unless user_owns_checkin?
        flash[:notice] = "You do not own that checkin"
        redirect_to root_path
      end
    end

end
