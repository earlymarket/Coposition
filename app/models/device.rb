class Device < ActiveRecord::Base
  include SlackNotifiable

  belongs_to :user
  has_many :checkins
  has_many :device_developer_privileges
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

  ###########

  ## Metadata ##

  def checkins_over(param, range)
    checkins.where("extract( #{param} from created_at) IN (?)", range)
  end

  def most_frequent_coords_over(param, range)
    checkins_over(param, range).most_common_coords
  end

  def recent_checkins(range)
    today = Date.today
    past = today - range
    checkins.where(["created_at >= ? and created_at <= ?", past.beginning_of_day, today.end_of_day])
  end

  def recent_cities_coords(range)
    lat, lng = checkins.most_common_coords[0], checkins.most_common_coords[1]
    recent_checks = recent_checkins(range)
    checks = recent_checks.where("(lat - ?).abs > 1 OR (lng - ?).abs > 1", lat, lng).select("DISTINCT lat,lng")
    checks.map do |check|
      binding.pry
      [check.lat, check.lng]
    end
  end

end