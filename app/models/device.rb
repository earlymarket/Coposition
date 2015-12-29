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
    "A device has been created by #{user.username}"
  end

  # Metadata
  def checkins_at(param, value)
    checkins.where("extract( #{param} from created_at) = ?", value)
  end

  def checkins_over_range(time_range)
    checks = []
    time_range.step do |hour_v|
      checks << checkins_at('hour', hour_v)
    end
    checks = checks.reject { |c| c.empty? }
    checks.flatten
  end

  def most_frequent_address(checkins = self.checkins)
    params_array = []
    checkins.each do |checkin|
      params_array << checkin.address unless checkin.address.nil?
    end
    params_hash = params_array.reduce(Hash.new(0)) { |param, count| param[count] += 1; param }
    params_hash.max_by{|k,v| v}
  end

  def most_frequent_address_at(time_range)
    most_frequent_address(checkins_over_range(time_range))[0]
  end

  # Probably too complicated for actual use.
=begin 
  def location_at(day_v, month_v, year_v, hour_v)
    checkins = checkins.where('extract (day from created_at) = ? AND extract(month from created_at) = ? AND extract(year from created_at) = ? AND extract(hour from created_at) = ?', day_v, month_v, year_v, hour_v)
    if checkins.exists?
      checkins.each do |checkin|
        return checkin.address unless checkin.address.nil?
      end
      return "No address for checkins at this date"
    end
    return "No Checkins at date"
  end
=end

end