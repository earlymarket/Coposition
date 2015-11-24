class Device < ActiveRecord::Base
  belongs_to :user
  has_many :checkins
  has_many :redbox_checkins
  has_many :device_developer_privileges
  has_many :developers, through: :device_developer_privileges

  before_create do |dev|
    dev.uuid = generate_uuid
  end

  # TODO: refactor duplicated code (duped with developer)

  def generate_uuid
    SecureRandom.uuid
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
end