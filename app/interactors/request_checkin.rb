class RequestCheckin
  include Interactor

  delegate :current_user, :id, to: :context

  def call
    broadcast_request
    firebase_request_notification
  end

  private

  def broadcast_request
    ActionCable.server.broadcast "friends_#{id}",
      action: "request_checkin",
      message: message
  end

  def firebase_request_notification
    Firebase::Push.call(
      topic: id,
      notification: {
        body: message,
        title: "Check-in request"
      }
    )
  end

  def username
    current_user.username.present? ? current_user.username : current_user.email
  end

  def message
    "#{username} has requested a location update from you"
  end
end
