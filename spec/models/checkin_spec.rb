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

    it "should take a string with a GPS and return an object" do
      @checkin = Checkin.create_from_string(RequestFixture.w_gps)
      expect(@checkin.to_json).to eq Checkin.last.to_json
      expect(@checkin.status).to eq "A"
      expect(@checkin.imei).to eq "356938035643809"
    end

    it "should take a string without a GPS and return an object" do
      @checkin = Checkin.create_from_string(RequestFixture.no_gps)
      expect(@checkin.to_json).to eq Checkin.last.to_json
    end
  end

end