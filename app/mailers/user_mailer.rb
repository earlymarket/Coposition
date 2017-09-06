class UserMailer < ApplicationMailer
  def invite_email(address)
    invite_mail = SendGrid::Mail.new
    invite_mail.from = SendGrid::Email.new(email: "coposition@support.com")
    invite_mail.subject = "Coposition Invite"
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: address))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-address-", value: address))
    invite_mail.add_personalization(personalization)
    invite_mail.template_id = "b97d0595-a77e-46ae-838b-ceb1c6785fee"

    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    sg.client.mail._("send").post(request_body: invite_mail.to_json)
  end

  def add_user_email(approvable, user, from_developer)
    return unless user.subscription
    @unsubscribe = unsubscribe_link(user)
    @url = "https://coposition.com/users/#{user.id}/#{from_developer ? 'apps' : 'friends'}"
    @from = from_developer ? approvable.company_name : approvable.email
    mail(to: user.email, subject: "Coposition approval request from #{@from}")
  end

  def no_activity_email(user)
    return unless user.subscription
    @unsubscribe = unsubscribe_link(user)
    @inactive_devices = user.devices.inactive
    @email = user.email
    @url = "https://coposition.com/users/#{user.id}/devices"
    @forgot_password = "https://coposition.com/users/password/new"
    mail(to: @email, subject: "Coposition activity")
  end

  private

  def unsubscribe_link(user)
    Rails.application.message_verifier(:unsubscribe).generate(user.id)
  end
end
