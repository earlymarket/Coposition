class DeviceDeveloperPrivilege < ActiveRecord::Base
  validates :developer, uniqueness: { scope: :device }

  belongs_to :device
  belongs_to :developer

  before_create do |priv|
    priv.privilege = :complete
  end


  # At the moment, only complete/disallowed are used. enum used for
  # extensibility.
  enum privilege: [:complete, :fogged, :disallowed]

end