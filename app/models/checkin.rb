class Checkin < ActiveRecord::Base
  include SwitchFogging

  validates :lat, presence: :true
  validates :lng, presence: :true
  belongs_to :device

  delegate :user, to: :device

  default_scope { order(created_at: :desc) }
  scope :since, -> (date) { where("created_at > ?", date)}
  scope :before, -> (date) { where("created_at < ?", date)}

  reverse_geocoded_by :lat, :lng do |obj,results|
    if results.present?
      results.first.methods.each do |m|
        obj.send("#{m}=", results.first.send(m)) if column_names.include? m.to_s
      end
    end
  end


  after_create do
    if device
      self.uuid = device.uuid
      self.fogged = device.fogged
      device.checkins << self
      reverse_geocode! if device.checkins.count == 1
      add_fogged_info
    else
      raise "Checkin is not assigned to a device." unless Rails.env.test?
    end
  end

  def get_data
    fogged_checkin = self
    if fogged?
      fogged_checkin.address = "#{nearest_city.name}, #{nearest_city.country_code}"
      fogged_checkin.lat = self.fogged_lat || nearest_city.latitude || self.lat + rand(-0.5..0.5)
      fogged_checkin.lng = self.fogged_lng || nearest_city.longitude || self.lng + rand(-0.5..0.5)
      fogged_checkin
    else
      self
    end
  end

  def reverse_geocode!
    unless reverse_geocoded?
      reverse_geocode
      save
    end
    self
  end

  def reverse_geocoded?
    address != 'No address available'
  end

  def nearest_city
    center_point = [self.lat, self.lng]
    box = Geocoder::Calculations.bounding_box(center_point, 20)
    @nearest_city ||= City.near(self).within_bounding_box(box).first || NoCity.new
  end

  def add_fogged_info
    self.fogged_lat ||= nearest_city.latitude || self.lat + rand(-0.5..0.5)
    self.fogged_lng ||= nearest_city.longitude || self.lat + rand(-0.5..0.5)
    self.fogged_area ||= nearest_city.name
    save
  end

  def resolve_address(permissible, type)
    if type == "address"
      reverse_geocode!
      get_data unless device.can_bypass_fogging?(permissible)
      self
    else
      get_data unless device.can_bypass_fogging?(permissible)
      self.slice(:id, :uuid, :lat, :lng, :created_at, :updated_at, :fogged)
    end
  end

  def self.hash_group_and_count_by(attribute)
    select(&attribute).group_by(&attribute).inject({}) do |hash, (key,checkins)|
      hash[key] = checkins.length
      hash
    end.sort_by{ |_, count| count }.reverse!
  end

  def self.percentage_increase(time_range)
    recent_checkins_count = where(created_at: 1.send(time_range).ago..Time.now).count.to_f
    older_checkins_count = where(created_at: 2.send(time_range).ago..1.send(time_range).ago).count.to_f
    if recent_checkins_count > 0 && older_checkins_count > 0
      (((recent_checkins_count/older_checkins_count)-1)*100).round(2)
    end
  end
end
