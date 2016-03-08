module FriendsHelper

  def friends_name(friend)
    friend.username || friend.email.split("@").first
  end

end
