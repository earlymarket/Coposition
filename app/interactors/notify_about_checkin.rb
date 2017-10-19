class NotifyAboutCheckin
  include Interactor

  delegate :device, :checkin, to: :context

  def call
    device.notify_subscribers("new_checkin", checkin)
    broadcast_checkin_for_friends
    broadcast_checkin_for_user
  end

  private

  def broadcast_checkin_for_user
    return unless friend_online?(device.user)
    ActionCable.server.broadcast "friends_#{device.user.id}",
      action: "checkin",
      privilege: "complete",
      checkin: hashed_checkin
  end

  def broadcast_checkin_for_friends
    device.user.friends.find_each do |friend|
      next unless friend_online?(friend) && broadcast_checkin?(friend)
      ActionCable.server.broadcast "friends_#{friend.id}",
        action: "checkin",
        privilege: device.privilege_for(friend),
        checkin: hashed_checkin
    end
  end

  def hashed_checkin
    checkin.attributes.tap do |checkin_h|
      checkin_h["user_id"] = device.user_id
      checkin_h["device"] = device.name
    end
  end

  def friend_online?(friend)
    return false if Rails.env.test?
    ConnectedList.all.include?(friend.id.to_s)
  end

  def broadcast_checkin?(friend)
    allowed_checkin = device.safe_checkin_info_for(permissible: friend, action: "last", type: "address")[0]
    allowed_checkin && allowed_checkin["id"] == checkin.id
  end
end
