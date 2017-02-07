class FriendChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "friends_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def checkin
  end
end
