class Device < ActiveRecord::Base
  include SlackNotifiable
  include SwitchFogging

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, :source_type => "Developer"
  has_many :permitted_users, through: :permissions, source: :permissible, :source_type => "User"

  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def construct(current_user, device_name)
    update(user: current_user, name: device_name)
    developers << current_user.developers
    permitted_users << current_user.friends
  end

  def permitted_history_for(permissible)
    return Checkin.none if permission_for(permissible).privilege == "disallowed"

    if permission_for(permissible).privilege == "last_only"
      can_bypass_delay?(permissible) ? Checkin.where(id: checkins.last.id) : Checkin.where(id: checkins.before(delayed.to_i.minutes.ago).last.id)
    else
      can_bypass_delay?(permissible) ? checkins : checkins.before(delayed.to_i.minutes.ago)
    end

  end

  def permission_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s)
  end

  def can_bypass_fogging?(permissible)
    permission_for(permissible).bypass_fogging
  end

  def can_bypass_delay?(permissible)
    permission_for(permissible).bypass_delay
  end

  def slack_message
    "A new device has been created, id: #{self.id}, name: #{self.name}, user_id: #{self.user_id}. There are now #{Device.count} devices"
  end

  def set_delay(mins)
    if mins.to_i == 0
      update(delayed: nil)
    else
      update(delayed: mins)
    end
  end

end
