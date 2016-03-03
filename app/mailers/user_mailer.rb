class UserMailer < ApplicationMailer
  def invite_email(address)
    @address = address
    mail(to: @address, subject: 'Coposition invite')
  end
end
