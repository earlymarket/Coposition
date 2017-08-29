class Device < ApplicationRecord
  include SlackNotifiable, RemoveId, PublicActivity::Common

  belongs_to :user
  has_one :config, dependent: :destroy
  has_one :configurer, through: :config, source: :developer
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, source_type: "Developer"
  has_many :permitted_users, through: :permissions, source: :permissible, source_type: "User"
  has_attachment :csv, accept: :raw

  validates :name, uniqueness: { scope: :user_id }, if: :user_id

  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def safe_checkin_info_for(args)
    sanitized = filtered_checkins(args)
    sanitize_checkins(sanitized, args)
  end

  def filtered_checkins(args)
    sanitized = args[:copo_app] ? checkins : permitted_history_for(args[:permissible])
    sanitized.since_time(args[:time_amount], args[:time_unit])
             .near_to(args[:near])
             .on_date(args[:date])
             .unique_places_only(args[:unique_places])
             .limit_returned_checkins(args)
  end

  def sanitize_checkins(sanitized, args)
    if args[:type] == "address"
      sanitized.map(&:reverse_geocode!) unless args[:action] == "index" && args[:multiple_devices]
    end
    return sanitized if args[:copo_app]
    replace_checkin_attributes(sanitized, args[:permissible])
  end

  def replace_checkin_attributes(sanitized, permissible)
    if can_bypass_fogging?(permissible)
      sanitized.select(:id, :created_at, :updated_at, :device_id, :lat,
        :lng, :address, :city, :postal_code, :country_code, :speed, :altitude)
    elsif fogged
      sanitized.select("id", "created_at", "updated_at", "device_id", "fogged_lat AS lat", "fogged_lng AS lng",
        "fogged_city AS address", "fogged_city AS city", "fogged_country_code AS postal_code",
        "fogged_country_code AS country_code", "null AS speed", "null AS altitude")
    else
      sanitized.select("id", "created_at", "updated_at", "device_id", "output_lat AS lat", "output_lng AS lng",
        "output_address AS address", "output_city AS city", "output_postal_code AS postal_code",
        "output_country_code AS country_code", "speed", "altitude")
    end
  end

  def permitted_history_for(permissible)
    return Checkin.none if cloaked
    resolve_privilege(delayed_checkins_for(permissible), permissible)
  end

  def resolve_privilege(unresolved_checkins, permissible)
    return Checkin.none if privilege_for(permissible) == "disallowed"
    return unresolved_checkins if unresolved_checkins.empty?
    if privilege_for(permissible) == "last_only"
      unresolved_checkins.where(id: unresolved_checkins.first.id)
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
      before_delay_checkins
    end
  end

  def before_delay_checkins
    delayed ? checkins.where("checkins.created_at < ?", delayed.minutes.ago) : checkins
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

  def public_info
    # Clears out any potentially sensitive attributes, returns a normal ActiveRecord relation
    # Returns a normal ActiveRecord relation
    Device.select(%i(id user_id name alias published)).find(id)
  end

  def subscriptions(event)
    subs = Subscription.where(event: event).where(subscriber_id: user_id)
    subs if subs.present?
  end

  def notify_subscribers(event, data)
    return unless user.zapier_enabled && (subs = subscriptions(event))
    data = data.as_json
    data.merge!(remove_id.as_json)
    data.merge!(user.public_info.remove_id.as_json) if user
    subs.each { |subscription| subscription.send_data([data]) }
  end

  def self.public_info
    select(%i(id user_id name alias published))
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

  def self.inactive
    last_checkins_ids = Device.last_checkins.map(&:id)
    old_last_checkins = Checkin.where("id IN (?) AND created_at < ?", last_checkins_ids, 3.months.ago)
    device_ids = old_last_checkins.map(&:device_id)
    Device.where(id: device_ids)
  end
end
