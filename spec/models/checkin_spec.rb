require 'rails_helper'

RSpec.describe Checkin, type: :model do


  describe "realtionships" do

    it "should have a device" do
      checkin = FactoryGirl::create(:checkin)
      checkin.device = Device.create(imei: 1234)
      expect(checkin.device.imei).to eq "1234"
    end

  end
  
  describe "parsing" do
    it "should take a string without a GPS and return an object" do
      @checkin = Checkin.create_from_string(RequestFixture.no_gps)
      expect(@checkin.to_json).to eq Checkin.last.to_json
      expect(@checkin.imei).to eq "356938035643809"
      expect(@checkin.time).to eq "064951.000"
      expect(@checkin.date).to eq "260406"
      expect(@checkin.rotorspeed).to be 490.01
      expect(@checkin.device).to be nil
    end

    it "should add_device if asked to do so" do
      @checkin = Checkin.create_from_string(RequestFixture.no_gps, add_device: true)
      expect(@checkin.to_json).to eq Checkin.last.to_json
      expect(@checkin.imei).to eq "356938035643809"
      expect(@checkin.time).to eq "064951.000"
      expect(@checkin.date).to eq "260406"
      expect(@checkin.rotorspeed).to be 490.01
      expect(@checkin.device).to_not be nil
    end



    it "should take a string with a GPS and return an object" do
      @checkin = Checkin.create_from_string(RequestFixture.w_gps)
      expect(@checkin.to_json).to eq Checkin.last.to_json
      expect(@checkin.status).to eq "A"
      expect(@checkin.imei).to eq "356938035643809"
    end


    it "should return a new object without creating it, when asked" do
      @checkin = Checkin.new_from_string(RequestFixture.w_gps)
      expect(@checkin.id).to be nil
      expect(@checkin.status).to eq "A"
      expect(@checkin.imei).to eq "356938035643809"
    end
  end

end