class FriendChannel < ApplicationCable::Channel
  def subscribed
    stream_from "friends_#{user_id}"
    ConnectedList.add(user_id)
  end

  def unsubscribed
    ConnectedList.remove(user_id)
  end
end
