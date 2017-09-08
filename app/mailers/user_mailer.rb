class UserMailer < ApplicationMailer
  def invite_email(address)
    result = CreateSendgridTemplate.call(
      to: address, subject: "Coposition Invite", id: "b97d0595-a77e-46ae-838b-ceb1c6785fee",
      substitutions: [{ key: "-address-", value: address }]
    )
    send_mail(result)
  end

  def add_user_email(approvable, user, from_developer)
    return unless user.subscription
    result = CreateSendgridTemplate.call(
      to: user.email, subject: "Coposition approval request", id: "64b3b8c9-12ae-49bc-9983-2ac3e507ac0d",
      substitutions: [
        { key: "-url-", value: "https://coposition.com/users/#{user.id}/#{from_developer ? 'apps' : 'friends'}" },
        { key: "-from-", value: from_developer ? approvable.company_name : approvable.email },
        { key: "-unsubscribe-", value: settings_unsubscribe_url(id: unsubscribe_link(user)) }
      ]
    )
    send_mail(result)
  end

  def no_activity_email(user)
    return unless user.subscription
    result = CreateSendgridTemplate.call(
      to: user.email, subject: "Coposition activity", id: "b4437ee3-651a-4252-921b-c2a8ace722ac",
      substitutions: [
        { key: "-unsubscribe-", value: settings_unsubscribe_url(id: unsubscribe_link(user)) },
        { key: "-forgot-", value: "https://coposition.com/users/password/new" },
        { key: "-url-", value: "https://coposition.com/users/#{user.id}/devices" },
        { key: "-email-", value: user.email }
      ],
      content: no_activity_content(user)
    )
    send_mail(result)
  end

  private

  def no_activity_content(user)
    return "" if (inactive = user.devices.inactive).blank?
    content = "<p>You have not checked in on the following devices in over 3 months:</p>"
    content += "<ul>"
    inactive.each do |device|
      content += "<li><a href=#{url + '/' + device.id.to_s}>" + device.name + "</a></li>"
    end
    content += "</ul>"
    content
  end

  def send_mail(result)
    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    sg.client.mail._("send").post(request_body: result.mail.to_json)
  end

  def unsubscribe_link(user)
    Rails.application.message_verifier(:unsubscribe).generate(user.id)
  end
end
