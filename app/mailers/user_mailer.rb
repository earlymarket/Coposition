class UserMailer < ApplicationMailer
  def invite_email(address)
    @url = "https://coposition.com/users/sign_up?email=#{address}"
    mail(to: address, subject: 'Coposition invite')
  end

  def add_user_email(approvable, user, from_developer)
    @url = "https://coposition.com/users/#{user.id}/#{from_developer ? 'apps' : 'friends'}"
    @from = from_developer ? approvable.company_name : approvable.email
    mail(to: user.email, subject: "Coposition approval request from #{@from}")
  end

  def no_activity_email(user)
    mail(to: user.email, subject: 'Coposition activity')
  end
end
