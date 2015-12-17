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
      if Rails.env.test?
        # TODO: Decide whether or not this is the best idea.
           # The alternative is to explicitly state this step in every test,
           # perhaps with a test helper?
        dev = Device.create(uuid: uuid)
        dev.checkins << self
        reverse_geocode!
      else
        raise "UUID #{uuid} does not match a device."
      end
    end
  end

  class << self

    def find_range(from, size)
      order(:id).find(range_array(from, size))
    end

    def non_geocoded_keys(exception: nil)
      (column_names - [exception]) - geocoded_keys
    end

    def geocoded_keys
      %w{address city country postal_code}
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

  def non_geocoded_data(exception: nil)
    self.as_json.except(*Checkin.geocoded_keys, exception)
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