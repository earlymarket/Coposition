class UserMailer < ApplicationMailer
  include AbstractController::Callbacks

  def invite_email(address)
    @url = "https://coposition.com/users/sign_up?email=#{address}"
    mail(to: address, subject: "Coposition invite")
  end

  def add_user_email(approvable, user, from_developer)
    @unsubscribe = unsubscribe_link(user)
    @url = "https://coposition.com/users/#{user.id}/#{from_developer ? 'apps' : 'friends'}"
    @from = from_developer ? approvable.company_name : approvable.email
    mail(to: user.email, subject: "Coposition approval request from #{@from}") if user.subscription
  end

  def no_activity_email(user)
    @unsubscribe = unsubscribe_link(user)
    @url = "https://coposition.com/users/#{user.id}/devices"
    mail(to: user.email, subject: "Coposition activity") if user.subscription
  end

  private

  def unsubscribe_link(user)
    Rails.application.message_verifier(:unsubscribe).generate(user.id)
  end
end
