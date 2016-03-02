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

  def checkins
    delayed? ? super.before(delayed.minutes.ago) : super
  end

  def permitted_history_for(permissible)
    approval_date = user.approval_for(permissible).approval_date
    can_show_history?(permissible) ? checkins : checkins.since(approval_date)
  end

  def permission_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s)
  end

  def can_show_history?(permissible)
    permission_for(permissible).show_history
  end

  def can_bypass_fogging?(permissible)
    permission_for(permissible).bypass_fogging
  end

  def slack_message
    device = Device.last
    "A new device has been created, id: #{device.id}, name: #{device.name}, user_id: #{device.user_id}. There are now #{Device.count} devices"
  end

end
