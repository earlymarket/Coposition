class UserMailer < ApplicationMailer
  def invite_email(user, friend_email)
    SendSendgridEmail.call(
      to: friend_email, subject: "Coposition Invite", id: "b97d0595-a77e-46ae-838b-ceb1c6785fee",
      substitutions: [
        { key: "-address-", value: friend_email },
        { key: "-from-", value: user.email }
      ]
    )
  end

  def invite_sent_email(user, friend_email)
    return unless user.subscription
    SendSendgridEmail.call(
      to: user.email, subject: "Coposition friend request sent", id: "3bc81984-bec7-49af-8612-4107c028f5f5",
      substitutions: [
        { key: "-user-", value: user.username.present? ? user.username : user.email },
        { key: "-address-", value: friend_email },
        { key: "-unsubscribe-", value: unsubscribe_link(user) },
        { key: "-forgot-", value: "https://coposition.com/users/password/new" }
      ]
    )
  end

  def add_user_email(user, friend, from_developer)
    return unless friend.subscription
    SendSendgridEmail.call(
      to: friend.email, subject: "Coposition approval request", id: "64b3b8c9-12ae-49bc-9983-2ac3e507ac0d",
      substitutions: [
        { key: "-url-", value: "https://coposition.com/users/#{friend.id}/#{from_developer ? 'apps' : 'friends'}" },
        { key: "-from-", value: from_developer ? user.company_name : user.email },
        { key: "-unsubscribe-", value: unsubscribe_link(friend) }
      ]
    )
  end

  def pending_request_email(approvable, user)
    return unless user.subscription
    SendSendgridEmail.call(
      to: user.email, subject: "Coposition approval request", id: "57af0f8b-2aa9-4621-86ce-139d527a57b8",
      substitutions: [
        { key: "-url-", value: "https://coposition.com/users/#{user.id}/friends" },
        { key: "-from-", value: approvable.email },
        { key: "-unsubscribe-", value: unsubscribe_link(user) }
      ]
    )
  end

  def request_accepted(user, friend)
    return unless user.subscription
    SendSendgridEmail.call(
      to: user.email, subject: "Coposition new friend", id: "dafcb547-5aec-4671-88a3-776cd38948a4",
      substitutions: [
        { key: "-user-", value: user.username.present? ? user.username : user.email },
        { key: "-friend-", value: friend.username.present? ? friend.username : friend.email },
        { key: "-unsubscribe-", value: unsubscribe_link(user) },
        { key: "-forgot-", value: "https://coposition.com/users/password/new" }
      ]
    )
  end

  def no_activity_email(device)
    return unless device.user.subscription
    SendSendgridEmail.call(
      to: device.user.email, subject: "Coposition activity", id: "b4437ee3-651a-4252-921b-c2a8ace722ac",
      substitutions: [
        { key: "-unsubscribe-", value: unsubscribe_link(device.user) },
        { key: "-forgot-", value: "https://coposition.com/users/password/new" },
        { key: "-url-", value: "https://coposition.com/users/#{device.user.id}/devices" },
        { key: "-email-", value: device.user.email }
      ],
      content: no_activity_content(device)
    )
  end

  private

  def no_activity_content(device)
    inactive = device.user.devices.inactive(1.day.ago)
    content = "<p>Your device #{device.name} has been inactive for at least 7 days. You can find further information on creating check-ins on our Help Page.</p>"
    content += "<p>You also haven't heard from these devices in a while:"
    content += "<ul>"
    inactive.each do |device|
      content += "<li><a href='https://coposition.com/users/#{device.user.id}/devices/' + device.id.to_s}>"
      content += device.name + "</a>"
      content += " - Auto check-in #{device.config.custom && device.config.custom["active"] ? boolean_to_state(device.config.custom["active"]) : 'off'}"
      content += "</li>"
    end
    content += "</ul>"
    content
  end

  def boolean_to_state(boolean)
    boolean ? "on" : "off"
  end

  def unsubscribe_link(user)
    settings_unsubscribe_url(id: Rails.application.message_verifier(:unsubscribe).generate(user.id))
  end
end
