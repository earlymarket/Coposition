class UserMailer < ApplicationMailer
  def invite_email(address)
    @address = address
    @url = 'https://coposition.com/users/sign_up'
    mail(to: @address, subject: 'Coposition invite')
  end
end
