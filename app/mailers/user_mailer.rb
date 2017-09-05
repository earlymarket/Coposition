class UserMailer < ApplicationMailer
  def invite_email(address)
    data = JSON.parse({
      "personalizations": [
        {
          "to": [{ "email": address }],
          "substitutions": { "-address-": address },
          "subject": "Coposition Invite"
        }
      ],
      "from": { "email": "coposition@support.com" },
      "template_id": "b97d0595-a77e-46ae-838b-ceb1c6785fee"
    }.to_json)
    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    sg.client.mail._("send").post(request_body: data)

    # sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    # response = sg.client._("templates/b97d0595-a77e-46ae-838b-ceb1c6785fee").get()
    # binding.pry
    # @url = "https://coposition.com/users/sign_up?email=#{address}"
    # mail(to: address, subject: "Coposition invite")
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
