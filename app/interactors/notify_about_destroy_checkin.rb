class NotifyAboutDestroyCheckin
  include Interactor

  delegate :device, :checkin, to: :context

  def call
    device.user.friends.find_each do |friend|
      next unless ConnectedList.all.include? friend.id.to_s
      ActionCable.server.broadcast "friends_#{friend.id}",
                                   action: "destroy",
                                   checkin: checkin.as_json,
                                   new: new_last_checkin(friend)
    end
  end

  private

  def new_last_checkin(friend)
    new_recent = device.safe_checkin_info_for(permissible: friend, action: "last", type: "address")[0]
    return unless new_recent
    new_recent = new_recent.attributes
    new_recent["device"] = device.name
    new_recent
  end
end
