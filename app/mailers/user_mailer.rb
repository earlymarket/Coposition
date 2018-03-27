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
    return unless user.email_subscription.friend_invite_sent
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

  def no_activity_email(user, inactive)
    return unless user.email_subscription.device_inactivity
    SendSendgridEmail.call(
      to: user.email, subject: "Coposition activity", id: "b4437ee3-651a-4252-921b-c2a8ace722ac",
      substitutions: [
        { key: "-unsubscribe-", value: unsubscribe_link(user) },
        { key: "-forgot-", value: "https://coposition.com/users/password/new" },
        { key: "-url-", value: "https://coposition.com/users/#{user.id}/devices" },
        { key: "-email-", value: user.username.present? ? user.username : user.email },
        { key: "-content-", value: no_activity_content(inactive) }
      ]
    )
  end

  private

  def no_activity_content(inactive)
    content = "<p>You haven't heard from these devices in a while:</p>"
    content += "<ul>"
    inactive.each do |dev|
      last = dev.checkins.first
      content += "<li><a href='https://coposition.com/users/#{dev.user.id}/devices/#{dev.id}?first_load=true'>"
      content += "#{dev.name}</a>"
      content += " - Auto check-in #{dev.config.custom && dev.config.custom['active'] ? 'on' : 'off'}"
      content += " - #{dev.config.custom && dev.config.custom['assigned'] ? 'Assigned' : 'Unassigned'}"
      content += " - Last checked in #{humanize_date(last.created_at)} near #{last.fogged_city}"
      content += "</li>"
    end
    content += "</ul>"
    content
  end

  def unsubscribe_link(user)
    unsubscribe_user_email_subscriptions_url(user_id: user.id, id: Rails.application.message_verifier(:unsubscribe).generate(user.id))
  end

  def humanize_date(date)
    date.strftime("%A #{date.day.ordinalize} %B %Y")
  end
end
