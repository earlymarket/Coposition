require "rails_helper"

RSpec.describe FriendsHelper, type: :helper do
  let(:friend) { FactoryGirl.create :user }
  let(:device) do
    dev = FactoryGirl.create(:device, user_id: friend.id)
    dev.checkins << [FactoryGirl.create(:checkin, device: dev), FactoryGirl.create(:checkin, device: dev)]
    dev
  end

  describe "#friends_device_last_checkin" do
    it "returns no location if user can not see any of friends checkins" do
      expect(helper.friends_device_last_checkin([])).to match("No location")
    end

    it "returns the last checkin address if it exists" do
      expect(helper.friends_device_last_checkin(device.checkins.first)).to match("Last available")
      expect(helper.friends_device_last_checkin(device.checkins.first)).to match(device.checkins.first.fogged_city.to_s)
    end
  end
end
