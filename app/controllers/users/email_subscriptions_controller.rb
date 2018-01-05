class Users::EmailSubscriptionsController < ApplicationController
  def unsubscribe
    user = Rails.application.message_verifier(:unsubscribe).verify(params[:id])
    @email_subscription = User.find(user).email_subscription
  end

  def update
    EmailSubscription.find(params[:id]).update(subscription_params)
    redirect_to root_url, notice: "Subscription settings updated"
  end

  private

  def subscription_params
    params.require(:email_subscription).permit(:device_inactivity, :friend_invite_sent)
  end
end
