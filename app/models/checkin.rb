class Checkin < ActiveRecord::Base
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
      device.checkins << self
      reverse_geocode! if device.checkins.count == 1
    else
      raise "UUID #{uuid} does not match a device." unless Rails.env.test?
    end
  end

  class << self

    def most_common_coords
      group(:lat, :lng).count.max_by{|_k,v| v}[0]
    end

  end

  # The method to be used for public-facing data 
  def get_data
    if device.fogged?
      self.lat = nearest_city.latitude
      self.lng = nearest_city.longitude
      self.address = "#{city}, #{country_code}"
    end

    self
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
    @nearest_city ||= City.where(name: city, country_code: country_code).near(self).first
  end
end