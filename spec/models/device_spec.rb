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
    expect(device.permission_for(developer).privilege).to eq "complete"
  end

  describe "slack" do
    it "should generate a helpful message for slack" do
      expect(device.slack_message).to eq "A new device has been created, id: #{device.id}, name: #{device.name}, user_id: #{device.user_id}. There are now #{Device.count} devices"
    end
  end
end
