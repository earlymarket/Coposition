class Checkin < ActiveRecord::Base

  belongs_to :device

  reverse_geocoded_by :lat, :lng do |obj,results|
    if geo = results.first
      obj.city    = geo.city
      obj.postal_code = geo.postal_code
      obj.country = geo.country_code
    end
  end


  after_create do
    device = Device.find_by(uuid: uuid)
    device = Device.create(uuid: uuid) unless device
    device.checkins << self
  end

  class << self

    def find_range(from, size)
      order(:id).find(range_array(from, size))
    end

    def non_geocoded_keys
      column_names - geocoded_keys
    end

    def geocoded_keys
      %w{address city country postal_code}
    end

  end

  def non_geocoded_data
    self.as_json.except(Checkin.geocoded_keys)
  end

  def reverse_geocode!
    reverse_geocode unless reverse_geocoded?
  end

  def reverse_geocoded?
    !address.nil?
  end

  protected

  def self.range_array(from, size)
    from = [from]
    (size - 1).times {|x| from << (from.last + 1)}
    from
  end
end