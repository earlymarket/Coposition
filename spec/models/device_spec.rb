require 'rails_helper'

RSpec.describe Device, type: :model do

  let(:developer) { FactoryGirl::create :developer }
  let(:device) do 
    dev = FactoryGirl::create(:device)
    dev.developers << developer
    dev
  end
  let(:checkins) do
    device.checkins << FactoryGirl::create(:checkin)
  end

  describe "relationships" do

    it "should have some checkins" do
      expect(device.checkins).to match_array(checkins)
    end

    it "should have some approved developers" do
      expect(device.developers.first).to eq developer
    end

  end

  it "should get the privilege level for a developer" do
    expect(device.privilege_for developer).to eq "complete"
  end

  it "should change privilege levels for a developer" do
    expect(device.privilege_for developer).to eq "complete"
    
    device.change_privilege_for(developer, 2)

    expect(device.privilege_for developer).to eq "disallowed"

    device.change_privilege_for(developer, "complete")

    expect(device.privilege_for developer).to eq "complete"

    device.change_privilege_for(developer, device.reverse_privilege_for(developer))
  
    expect(device.privilege_for developer).to eq "disallowed"
  end

  it "should create a checkin for a device" do
    count = device.checkins.count
    device.create_checkin(lat: 51.588330, lng: -0.513069)
    expect(device.checkins.count).to be count+1
  end
end