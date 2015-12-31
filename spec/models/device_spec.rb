require 'rails_helper'

RSpec.describe Device, type: :model do

  let(:developer) { FactoryGirl::create :developer }
  let(:device) do 
    dev = FactoryGirl::create(:device)
    dev.developers << developer
    dev
  end
  let(:checkins) do
    checks = [FactoryGirl::create(:checkin)]
    checks << FactoryGirl::create(:checkin)
    device.checkins << checks
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
  
  describe "metadata" do
    it "should get the most address visited most during a specific time period" do
      expect(device.checkins).to match_array(checkins)
      expect(device.most_frequent_coords_over('hour', 0..24)).to eq [51.58833, -0.513069]
    end
  end
end