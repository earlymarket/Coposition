class FriendChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "friend_#{uuid}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def checkin
  end
end
