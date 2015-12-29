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
  def checkins_at(hour)
    checkins.where('extract(hour from created_at) = ?', hour)
  end

  def checkins_over_range(time_range)
    checks = []
    time_range.step do |hour|
      checks << checkins_at(hour)
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

  def location_at(hour)
    if checkins_at(hour).exists?
      checkins_at(hour).each do |checkin|
        unless checkin.address.nil?
          return checkin.address
        end
      end
      return "No address for checkins at this hour"
    end
    return "No Checkins at #{hour}"
  end

end