class UserMailer < ApplicationMailer
  def invite_email(address)
    @url = "https://coposition.com/users/sign_up?email=#{address}"
    mail(to: address, subject: 'Coposition invite')
  end

  def add_user_email(from, added_user, developer)
    @url = "https://coposition.com/users/#{added_user.id}/"
    @url += developer ? 'apps' : 'friends'
    @from = developer ? from.company_name : from.email
    mail(to: added_user.email, subject: "Coposition approval request from #{@from}")
  end
end
