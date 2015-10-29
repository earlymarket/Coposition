class DeviceDeveloperPrivilege < ActiveRecord::Base
  validates :developer, uniqueness: { scope: :device }

  belongs_to :device
  belongs_to :developer

  before_create do |priv|
    priv.privilege = :complete
  end

  enum privilege: [:complete, :fogged, :disallowed]

end