class Checkin < ActiveRecord::Base

  belongs_to :device

  def self.string_order 
    [:status, :lat, :n_s, :lng, :e_w, :gspeed, :altitude, 
      :course, :time, :date, :rotorspeed, :enginespeed, :imei]
  end

  def self.create_from_string (string)
    @string = string

    device = Device.where(imei: hash[:imei]).first
    device = Device.create(imei: hash[:imei]) unless device
    device.checkins << create(hash)
  end

  protected

  def self.hash
    @hash ||= string_order.zip(@string.split(delimiter)).to_h
  end

  private

  def self.delimiter
    "|"
  end

end