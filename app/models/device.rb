class Device < ActiveRecord::Base
  include SlackNotifiable
  include SwitchFogging

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, :source_type => "Developer"
  has_many :allowed_user_permissions, ->  { where.not privilege: 0 }, class_name: 'Permission'
  has_many :permitted_users, through: :allowed_user_permissions, source: :permissible, :source_type => "User"

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
    sanitized = permitted_history_for(args[:permissible]).limit_returned_checkins(args)
    sanitized = sanitized.map(&:reverse_geocode!) if args[:type] == 'address'
    sanitized = sanitized.map(&:replace_foggable_attributes) unless can_bypass_fogging?(args[:permissible])
    sanitized = sanitized.map(&:public_info)
  end

  def permitted_history_for(permissible)
    resolve_privilege(delayed_checkins_for(permissible), permissible)
  end

  def resolve_privilege(unresolved_checkins, permissible)
    return Checkin.none if privilege_for(permissible) == 'disallowed'
    if privilege_for(permissible) == 'last_only'
      return Checkin.none if unresolved_checkins.empty?
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
    "A new device has been created, id: #{self.id}, name: #{self.name}, user_id: #{self.user_id}. There are now #{Device.count} devices"
  end

  def set_delay(mins)
    mins.to_i == 0 ? update(delayed: nil) : update(delayed: mins)
  end

  def humanize_delay
    if delayed.nil?
      "#{name} is not delayed."
    elsif delayed < 60
      "#{name} delayed by #{delayed} #{'minute'.pluralize(delayed)}."
    elsif delayed < 1440
      "#{name} delayed by #{delayed/60} #{'hour'.pluralize(delayed/60)} and #{delayed%60} #{'minutes'.pluralize(delayed%60)}."
    else
      "#{name} delayed by #{delayed/1440} #{'day'.pluralize(delayed/1440)}."
    end
  end

  def public_info
    # Clears out any potentially sensitive attributes
    # Returns a normal ActiveRecord relation
    Device.select([:id, :user_id, :name, :alias, :published]).find(self.id)
  end

  def subscriptions(event)
    Subscription.where(event: event).where(subs[:user_id].eq(user_id).or(subs[:user_id].in(permitted_users.ids)))
  end

  def notify_subscribers(event, data)
    subscriptions(event).each do |subscription|
      subscription.send_data(data)
    end unless subscriptions(event).empty?
  end

  def self.public_info
    select([:id, :user_id, :name, :alias, :published])
  end

  private

    def subs
      Subscription.arel_table
    end

end
