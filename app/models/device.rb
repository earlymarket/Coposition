class Device < ActiveRecord::Base
  belongs_to :user
  has_many :checkins
  has_many :redbox_checkins
  has_many :device_developer_privileges
  has_many :developers, through: :device_developer_privileges

  def privilege_for(dev)
    device_developer_privileges.find_by(developer: dev.id).privilege
  end
end