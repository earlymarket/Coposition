class Checkin < ActiveRecord::Base

  belongs_to :device

  reverse_geocoded_by :lat, :lng do |obj,results|
    if geo = results.first
      obj.address = results.first.formatted_address
      obj.city    = geo.city
      obj.postal_code = geo.postal_code
      obj.country = geo.country_code
    end
  end


  after_create do
    device = Device.find_by(uuid: uuid)
    if device
      device.checkins << self
      reverse_geocode! if device.checkins.count == 1
    else
      if Rails.env.test?
        # TODO: Decide whether or not this is the best idea
        # The alternative is to explicitly state this step in every test
        # Perhaps with a test helper?
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

  protected

  def self.range_array(from, size)
    from = [from]
    (size - 1).times {|x| from << (from.last + 1)}
    from
  end
end