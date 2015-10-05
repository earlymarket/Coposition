class Checkin < ActiveRecord::Base

  belongs_to :device

  after_create do
    device = Device.find_by(uuid: uuid)
    device = Device.create(uuid: uuid) unless device
    device.checkins << self
  end

  def self.find_range(from, size)
    order(:id).find(range_array(from, size))
  end

  protected

  def self.range_array(from, size)
    from = [from]
    (size - 1).times {|x| from << (from.last + 1)}
    from
  end

end