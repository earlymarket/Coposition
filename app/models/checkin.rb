class Checkin < ActiveRecord::Base

  belongs_to :device


  # Dynamic methods for doing something with a checkin string
  [:new, :create].each do |prefix|
    define_singleton_method("#{prefix}_from_string") do |string, options={}|
      hash = to_hash(string)

      new_checkin = send(prefix, hash)
      if options[:add_device]
        device = Device.where(imei: hash[:imei]).first
        device = Device.create(imei: hash[:imei]) unless device
        device.checkins << new_checkin
      end
      new_checkin
    end
  end

  def self.string_order
    [:imei,:enginespeed,:rotorspeed,:date,:time,:course,:altitude,
      :gspeed,:e_w,:lng,:n_s,:lat,:status]
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

  def self.to_hash(string)
    string_order.zip(string.split(delimiter)).to_h
  end

  private

  def self.delimiter
    "|"
  end

end