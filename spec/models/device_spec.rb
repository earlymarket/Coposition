require 'rails_helper'

RSpec.describe Device, type: :model do

  before do
    @device = Device.create(uuid: 1234)
  end

  describe "realtionships" do

    it "should have some redbox checkins" do
      redbox_checkins = [FactoryGirl::create(:redbox_checkin)]
      redbox_checkins << FactoryGirl::create(:redbox_checkin)
      @device.redbox_checkins << redbox_checkins
      expect(@device.redbox_checkins).to match_array(redbox_checkins)
    end

    it "should have some checkins" do
      checkins = [FactoryGirl::create(:checkin)]
      checkins << FactoryGirl::create(:checkin)
      @device.checkins << checkins
      expect(@device.checkins).to match_array(checkins)
    end

  end

end