class DeviceApprovedDeveloper < ActiveRecord::Base
  belongs_to :device
  belongs_to :developer

end