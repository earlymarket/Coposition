class NotifyAboutDestroyCheckin
  include Interactor

  delegate :device, :checkin, to: :context

  def call
    device.broadcast_destroy_checkin_for_friends(checkin)
  end
end
