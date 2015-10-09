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

  def self.find_range(from, size)
    order(:id).find(range_array(from, size))
  end

  def city
  	reverse_geocode unless address
  	super
  end

  def country
  	reverse_geocode unless address
  	super
  end

  def postal_code
  	reverse_geocode unless address
  	super
  end

  protected

  def self.range_array(from, size)
    from = [from]
    (size - 1).times {|x| from << (from.last + 1)}
    from
  end
end