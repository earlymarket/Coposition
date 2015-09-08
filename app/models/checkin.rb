class Checkin < ActiveRecord::Base

  def self.string_order 
    [:status, :lat, :n_s, :lng, :e_w, :gspeed, :altitude, 
      :course, :time, :date, :rotorspeed, :enginespeed]
  end

  def self.create_from_string (string)
    @string = string
    create to_hash
  end

  protected

  def self.to_hash
    string_order.zip(@string.split(delimiter)).to_h
  end

  private

  def self.delimiter
    "|"
  end

end