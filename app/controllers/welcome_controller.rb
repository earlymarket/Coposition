class WelcomeController < ApplicationController

  def index
  	render "placeholder", layout: false if (Rails.env == "production" && !params[:admin] && !signed_in?)
  end

  ## TODO: Remove for live beta
  def reset_for_demo
    if params[:pass] == Rails.application.secrets.api_reset_pass.to_s
      Approval.destroy_all
      Device.destroy_all
      Checkin.destroy_all
      flash[:notice] = "Approvals, devices and checkins deleted."
      redirect_to root_url
    end
  end
  ##

end
