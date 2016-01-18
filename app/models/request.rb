class Request < ActiveRecord::Base
  belongs_to :developer
  scope :recent, ->(time) { where("created_at > ?", time) }

  def description
    {
      "api/v1/users/devices": 
      {
        "index": "getting a list of your devices and last checkins",
        "show": "getting a specific device and it's last checkin"
       },
      "api/v1/users/devices/checkins":
      {
        "index": "getting a list of all checkins for a device",
        "last": "getting the last checkin for a device"
      },
      "api/v1/users":
      {
        "last_checkin": "getting your last checkin",
        "all_checkins": "getting a list of all of your checkins"
      }
    }
  end


end