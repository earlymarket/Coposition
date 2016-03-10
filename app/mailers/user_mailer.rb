class UserMailer < ApplicationMailer
  def invite_email(address)
    mail(to: address, subject: 'Coposition invite')
  end
end
