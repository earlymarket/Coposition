class SettingsController < ApplicationController
  def unsubscribe
    user = Rails.application.message_verifier(:unsubscribe).verify(params[:id])
    @user = User.find(user)
  end

  def update
    User.find(params[:id]).update(user_params)
    redirect_to root_url, notice: "Subscription Cancelled"
  end

  private

  def user_params
    params.require(:user).permit(:subscription)
  end
end
