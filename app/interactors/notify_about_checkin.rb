class NotifyAboutCheckin
  include Interactor

  delegate :device, :checkin, to: :context

  def call
    device.notify_subscribers("new_checkin", checkin)
    device.broadcast_checkin_for_friends(checkin)
  end
end
