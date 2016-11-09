class Device < ApplicationRecord
  include SlackNotifiable, SwitchFogging, HumanizeMinutes, RemoveId

  belongs_to :user
  has_one :config, dependent: :destroy
  has_one :configurer, through: :configs, source: :developer
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, source_type: 'Developer'
  has_many :permitted_users, through: :permissions, source: :permissible, source_type: 'User'
  has_many :allowed_user_permissions, -> { where.not privilege: 0 }, class_name: 'Permission'
  has_many :allowed_users, through: :allowed_user_permissions, source: :permissible, source_type: 'User'

  validates :name, uniqueness: { scope: :user_id }, if: :user_id

  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def construct(current_user, device_name)
    if update(user: current_user, name: device_name)
      developers << current_user.developers
      permitted_users << current_user.friends
    end
  end

  def safe_checkin_info_for(args)
    sanitized = args[:copo_app] ? checkins : permitted_history_for(args[:permissible])
    sanitized = sanitized.since(args[:time_amount].send(args[:time_unit]).ago) if args[:time_unit] && args[:time_amount]
    sanitized = sanitized.near(args[:near].split(',')[0].to_f, args[:near].split(',')[1].to_f) if args[:near]
    if args[:date]
      date = Date.parse(args[:date])
      sanitized = sanitized.where(created_at: date.midnight..date.end_of_day)
    end
    sanitized = sanitized.limit_returned_checkins(args)
    sanitized = sanitized.map(&:reverse_geocode!) if args[:type] == 'address'
    return sanitized if args[:copo_app]
    sanitized = sanitized.map(&:replace_foggable_attributes) unless can_bypass_fogging?(args[:permissible])
    sanitized.map(&:public_info)
  end

  def permitted_history_for(permissible)
    resolve_privilege(delayed_checkins_for(permissible), permissible)
  end

  def resolve_privilege(unresolved_checkins, permissible)
    return Checkin.none if privilege_for(permissible) == 'disallowed'
    return unresolved_checkins if unresolved_checkins.empty?
    if privilege_for(permissible) == 'last_only'
      Checkin.where(id: unresolved_checkins.first.id)
    else
      unresolved_checkins
    end
  end

  def privilege_for(permissible)
    permission_for(permissible).privilege
  end

  def delayed_checkins_for(permissible)
    if can_bypass_delay?(permissible)
      checkins
    else
      checkins.before(delayed.to_i.minutes.ago)
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
    "A new device was created, id: #{id}, name: #{name}, user_id: #{user_id}. There are now #{Device.count} devices"
  end

  def update_delay(mins)
    mins.to_i.zero? ? update(delayed: nil) : update(delayed: mins)
  end

  def humanize_delay
    if delayed.nil?
      "#{name} is not delayed."
    else
      "#{name} delayed by #{humanize_minutes(delayed)}."
    end
  end

  def public_info
    # Clears out any potentially sensitive attributes, returns a normal ActiveRecord relation
    # Returns a normal ActiveRecord relation
    Device.select([:id, :user_id, :name, :alias, :published]).find(id)
  end

  def subscriptions(event)
    Subscription.where(event: event).where(subscriber_id: user_id)
  end

  def notify_friends(data)
    Subscription.where(event: 'friend_new_checkin').where(subscriber_id: user.friends).each do |sub|
      checkin = safe_checkin_info_for(permissible: sub.subscriber, type: 'address', action: 'last').first
      next unless checkin && checkin['id'] == data['id'] && user.changed_location?
      checkin.merge!(public_info.remove_id.as_json)
      checkin.merge!(user.public_info.remove_id.as_json)
      sub.send_data([checkin])
    end
  end

  def notify_subscribers(event, data)
    notify_friends(data) if event == 'new_checkin'
    return unless (subs = subscriptions(event))
    data = data.as_json
    data.merge!(remove_id.as_json)
    data.merge!(user.public_info.remove_id.as_json) if user
    subs.each { |subscription| subscription.send_data([data]) }
  end

  def self.public_info
    select([:id, :user_id, :name, :alias, :published])
  end

  def self.last_checkins
    all.map { |device| device.checkins.first if device.checkins.exists? }.compact.sort_by(&:created_at).reverse
  end

  def self.geocode_last_checkins
    all.each { |device| device.checkins.first.reverse_geocode! if device.checkins.exists? }
  end

  def self.ordered_by_checkins
    device_ids = last_checkins.map(&:device_id)
    ordered_devices = all.index_by(&:id).values_at(*device_ids)
    ordered_devices += all
    ordered_devices.uniq
  end
end
