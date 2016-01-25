class Device < ActiveRecord::Base
  include SlackNotifiable
  include SharedMethods

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, -> { where "privilege = 0" }, through: :permissions, source: :permissible, :source_type => "Developer"
  has_many :permitted_users, -> { where "privilege = 0" }, through: :permissions, source: :permissible, :source_type => "User"


  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def checkins
    delayed? ? super.where("created_at < ?", delayed.minutes.ago) : super
  end

  def privilege_for(dev)
    permissions.find_by(permissible_id: dev.id, permissible_type: 'Developer').privilege
  end

  def reverse_privilege_for(dev)
    if privilege_for(dev) == "complete"
      "disallowed"
    else
      "complete"
    end
  end

  def create_checkin(lat:, lng:)
    checkins << Checkin.create(uuid: uuid, lat: lat, lng: lng)
  end

  def change_privilege_for(dev, new_privilege)
    if dev.respond_to? :id
      dev = dev.id
    end
    record = permissions.find_by(permissible_id: dev)
    record.privilege = new_privilege
    record.save
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