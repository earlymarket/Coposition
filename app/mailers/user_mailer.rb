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
    url = "https://coposition.com/users/#{user.id}/#{from_developer ? 'apps' : 'friends'}"
    from = from_developer ? approvable.company_name : approvable.email
    unsub = settings_unsubscribe_url(id: unsubscribe_link(user))
    add_mail = SendGrid::Mail.new
    add_mail.from = SendGrid::Email.new(email: "coposition@support.com")
    add_mail.subject = "Coposition approval request"
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: user.email))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-url-", value: url))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-from-", value: from))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-unsubscribe-", value: unsub))
    add_mail.add_personalization(personalization)
    add_mail.template_id = "64b3b8c9-12ae-49bc-9983-2ac3e507ac0d"

    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    sg.client.mail._("send").post(request_body: add_mail.to_json)

    # return unless user.subscription
    # @unsubscribe = unsubscribe_link(user)
    # @url = "https://coposition.com/users/#{user.id}/#{from_developer ? 'apps' : 'friends'}"
    # @from = from_developer ? approvable.company_name : approvable.email
    # mail(to: user.email, subject: "Coposition approval request from #{@from}")
  end

  def no_activity_email(user)
    return unless user.subscription
    url = "https://coposition.com/users/#{user.id}/devices"
    content = ""
    if (inactive = user.devices.inactive).present?
      content += "<p>You have not checked in on the following devices in over 3 months:</p>"
      content += "<ul>"
      inactive.each do |device|
        content += "<li><a href=#{url + '/' + device.id.to_s}>" + device.name + "</a></li>"
      end
      content += "</ul>"
    end
    unsubscribe = settings_unsubscribe_url(id: unsubscribe_link(user))
    email = user.email
    forgot_password = "https://coposition.com/users/password/new"

    activity_mail = SendGrid::Mail.new
    activity_mail.from = SendGrid::Email.new(email: "coposition@support.com")
    activity_mail.subject = "Coposition activity"
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: email))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-unsubscribe-", value: unsubscribe))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-forgot-", value: forgot_password))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-url-", value: url))
    personalization.add_substitution(SendGrid::Substitution.new(key: "-email-", value: email))
    activity_mail.add_personalization(personalization)
    activity_mail.add_content(SendGrid::Content.new(type: "text/html", value: content)) if content.length
    activity_mail.template_id = "b4437ee3-651a-4252-921b-c2a8ace722ac"
    binding.pry
    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    sg.client.mail._("send").post(request_body: activity_mail.to_json)

    # return unless user.subscription
    # @unsubscribe = unsubscribe_link(user)
    # @inactive_devices = user.devices.inactive
    # @email = user.email
    # @url = "https://coposition.com/users/#{user.id}/devices"
    # @forgot_password = "https://coposition.com/users/password/new"
    # mail(to: @email, subject: "Coposition activity")
  end

  private

  def unsubscribe_link(user)
    Rails.application.message_verifier(:unsubscribe).generate(user.id)
  end
end
