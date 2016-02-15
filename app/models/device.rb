class Device < ActiveRecord::Base
  include SlackNotifiable
  include SharedMethods

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, :source_type => "Developer"
  has_many :permitted_users, through: :permissions, source: :permissible, :source_type => "User"

  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def checkins
    delayed? ? super.where("created_at < ?", delayed.minutes.ago) : super
  end

  def privilege_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s).privilege
  end

  def bypass_fogging_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s).bypass_fogging
  end

  def show_history_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s).show_history
  end

  def create_checkin(lat:, lng:)
    checkins << Checkin.create(uuid: uuid, lat: lat, lng: lng)
  end

  def device_checkin_hash
    hash = as_json
    hash[:last_checkin] = checkins.last.get_data if checkins.exists?
    hash
  end

  def slack_message
    "A new device has been created"
  end

end
