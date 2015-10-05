class RedboxCheckin < Checkin
  

  # Dynamic methods for doing something with a checkin string
  [:new, :create].each do |prefix|
    define_singleton_method("#{prefix}_from_string") do |string, options={}|
      hash = to_hash(string)

      new_checkin = send(prefix, hash)
      if options[:add_device]
        device = Device.where(uuid: hash[:uuid]).first
        device = Device.create(uuid: hash[:uuid]) unless device
        device.checkins << new_checkin
      end
      new_checkin
    end
  end

  def self.string_order
    [:uuid,:enginespeed,:rotorspeed,:date,:time,:course,:altitude,
      :gspeed,:e_w,:lng,:n_s,:lat,:status]
  end

end