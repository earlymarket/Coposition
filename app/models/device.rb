class Device < ActiveRecord::Base
  include SlackNotifiable
  include SwitchFogging

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, source_type: 'Developer'
  has_many :permitted_users, through: :permissions, source: :permissible, source_type: 'User'

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

  def permitted_history_for(permissible)
    return Checkin.none if permission_for(permissible).privilege == 'disallowed'
    if permission_for(permissible).privilege == 'last_only'
      if can_bypass_delay?(permissible)
        Checkin.where(id: checkins.first.id)
      elsif checkins.before(delayed.to_i.minutes.ago).present?
        Checkin.where(id: checkins.before(delayed.to_i.minutes.ago).first.id)
      else
        Checkin.none
      end
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
    "A new device was created, id: #{id}, name: #{name}, user_id: #{user_id}. There are now #{Device.count} devices"
  end

  def update_delay(mins)
    mins.to_i == 0 ? update(delayed: nil) : update(delayed: mins)
  end

  def humanize_delay
    if delayed.nil?
      "#{name} is not delayed."
    elsif delayed < 60
      "#{name} delayed by #{delayed} #{'minute'.pluralize(delayed)}."
    elsif delayed < 1440
      "#{name} delayed by #{delayed / 60} #{'hour'.pluralize(delayed / 60)}"\
      " and #{delayed % 60} #{'minutes'.pluralize(delayed % 60)}."
    else
      "#{name} delayed by #{delayed / 1440} #{'day'.pluralize(delayed / 1440)}."
    end
  end

  def public_info
    # Clears out any potentially sensitive attributes
    # Returns a normal ActiveRecord relation
    Device.select([:id, :user_id, :name, :alias, :published]).find(id)
  end

  def subscriptions(event)
    Subscription.where(event: event).where(user_id: user_id)
  end

  def notify_subscribers(event, data)
    zapier_data = [data]
    zapier_data << public_info unless data.model_name == 'Device'
    zapier_data << user.public_info if user
    subscriptions(event).each do |subscription|
      subscription.send_data(zapier_data)
    end unless subscriptions(event).empty?
  end

  def self.public_info
    select([:id, :user_id, :name, :alias, :published])
  end
end
