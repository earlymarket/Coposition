require 'rails_helper'

RSpec.describe Device, type: :model do

  before do
    @developer = FactoryGirl::create :developer
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

    it "should have some approved devleopers" do
      @device.developers << @developer
      expect( @device.developers.first ).to eq @developer
    end

  end

  it "should get the privilege level for a developer" do
    @device.developers << @developer
    expect(@device.privilege_for @developer).to eq "complete"
  end

  it "should change privilege levels for a developer" do
    @device.developers << @developer
    expect(@device.privilege_for @developer).to eq "complete"
    @device.change_privilege_for(@developer, 2)

    expect(@device.privilege_for @developer).to eq "disallowed"

    @device.change_privilege_for(@developer, "complete")

    expect(@device.privilege_for @developer).to eq "complete"

    @device.change_privilege_for(@developer, @device.reverse_privilege_for(@developer))
  
    expect(@device.privilege_for @developer).to eq "disallowed"
  end

end