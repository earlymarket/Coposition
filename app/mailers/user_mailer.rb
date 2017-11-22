class UserMailer < ApplicationMailer
  def invite_email(user, friend_email)
    SendSendgridEmail.call(
      to: address, subject: "Coposition Invite", id: "b97d0595-a77e-46ae-838b-ceb1c6785fee",
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

  def no_activity_email(user)
    return unless user.subscription
    SendSendgridEmail.call(
      to: user.email, subject: "Coposition activity", id: "b4437ee3-651a-4252-921b-c2a8ace722ac",
      substitutions: [
        { key: "-unsubscribe-", value: unsubscribe_link(user) },
        { key: "-forgot-", value: "https://coposition.com/users/password/new" },
        { key: "-url-", value: "https://coposition.com/users/#{user.id}/devices" },
        { key: "-email-", value: user.email }
      ],
      content: no_activity_content(user)
    )
  end

  private

  def no_activity_content(user)
    return "" if (inactive = user.devices.inactive).blank?
    content = "<p>You have not checked in on the following devices in over 3 months:</p>"
    content += "<ul>"
    inactive.each do |device|
      content += "<li><a href='https://coposition.com/users/#{user.id}/devices/' + device.id.to_s}>"
      content += device.name + "</a></li>"
    end
    content += "</ul>"
    content
  end

  def unsubscribe_link(user)
    settings_unsubscribe_url(id: Rails.application.message_verifier(:unsubscribe).generate(user.id))
  end
end
