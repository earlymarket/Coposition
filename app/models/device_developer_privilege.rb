class DeviceDeveloperPrivilege < ActiveRecord::Base
  belongs_to :device
  belongs_to :developer

  before_create do |priv|
    priv.privilege = :complete
  end

  enum privilege: [:complete, :fogged, :disallowed]

end