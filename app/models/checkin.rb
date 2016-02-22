class Checkin < ActiveRecord::Base
  include SwitchFogging

  validates :uuid, presence: :true
  validates :lat, presence: :true
  validates :lng, presence: :true
  belongs_to :device

  reverse_geocoded_by :lat, :lng do |obj,results|
    results.first.methods.each do |m|
      obj.send("#{m}=", results.first.send(m)) if column_names.include? m.to_s
    end
  end


  after_create do
    device = Device.find_by(uuid: uuid)
    if device
      self.fogged = device.fogged
      device.checkins << self
      reverse_geocode! if device.checkins.count == 1
    else
      raise "UUID #{uuid} does not match a device." unless Rails.env.test?
    end
  end

  # The method to be used for public-facing data
  def get_data
    fogged_checkin = self
    if fogged?
      fogged_checkin.address = "#{nearest_city.name}, #{nearest_city.country_code}"
      fogged_checkin.lat = self.lat + rand(-0.5..0.5)
      fogged_checkin.lng = self.lng + rand(-0.5..0.5)
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
    !address.nil?
  end

  def nearest_city
    @nearest_city ||= City.near(self).first || NoCity.new
  end
end
