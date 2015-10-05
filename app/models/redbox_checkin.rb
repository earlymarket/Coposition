class RedboxCheckin < Checkin
  

  # Dynamic methods for doing something with a checkin string
  [:new, :create].each do |prefix|
    define_singleton_method("#{prefix}_from_string") do |string|
      send(prefix, to_hash(string))
    end
  end

  def self.string_order
    [:uuid,:enginespeed,:rotorspeed,:date,:time,:course,:altitude,
      :gspeed,:e_w,:lng,:n_s,:lat,:status]
  end

  protected

  def self.to_hash(string)
    string_order.zip(string.split(delimiter)).to_h
  end

  def self.delimiter
    "|"
  end
end