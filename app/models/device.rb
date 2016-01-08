class Device < ActiveRecord::Base
  include SlackNotifiable

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :device_developer_privileges, dependent: :destroy
  has_many :developers, through: :device_developer_privileges

  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def checkins
    delayed? ? super.where("created_at < ?", delayed.minutes.ago) : super
  end


  def switch_fog
    self.fogged = !self.fogged
    save
    self.fogged
  end

  def privilege_for(dev)
    device_developer_privileges.find_by(developer: dev).privilege
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
    record = device_developer_privileges.find_by(developer: dev)
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