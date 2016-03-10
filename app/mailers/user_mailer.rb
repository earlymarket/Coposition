class UserMailer < ApplicationMailer
  def invite_email(address)
    mail(to: address, subject: 'Coposition invite')
  end

  def add_friend_email(user, friend)
    @url = "https://coposition.com/users/#{friend.id}/friends"
    @email = user.email
    mail(to: friend.email, subject: "Coposition friend request from #{@email}")
  end
end
