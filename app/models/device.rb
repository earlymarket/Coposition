class Device < ActiveRecord::Base
  belongs_to :user
  has_many :checkins
  has_many :redbox_checkins
  has_many :device_developer_privileges
  has_many :developers, through: :device_developer_privileges

  def privilege_for(dev)
    device_developer_privileges.find_by(developer: dev.id).privilege
  end

  def reverse_privilege_for(dev)
    if privilege_for(dev) == "complete"
      "disallowed"
    else
      "complete"
    end
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