require 'rails_helper'

RSpec.describe Device, type: :model do

  before do
    @device = Device.create(imei: 1234)
  end

  describe "realtionships" do

    it "should have some checkins" do
      checkins = [FactoryGirl::create(:checkin)]
      checkins << FactoryGirl::create(:checkin)
      @device.checkins << checkins
      expect(@device.checkins).to match_array(checkins)
    end

  end

end