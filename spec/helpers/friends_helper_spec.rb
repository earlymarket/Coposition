require "rails_helper"

RSpec.describe FriendsHelper, type: :helper do
  let(:friend) { create :user }
  let(:device) { create :device, user: friend }

  before { create_list :checkin, 2, device: device, city: "city" }

  describe "#friends_device_last_checkin" do
    it "returns no location if user can not see any of friends checkins" do
      expect(helper.friends_device_last_checkin([])).to match("No location")
    end

    it "returns the last checkin address if it exists" do
      expect(helper.friends_device_last_checkin(device.checkins.first)).to match("Last available")
      expect(helper.friends_device_last_checkin(device.checkins.first)).to match(device.checkins.first.city.to_s)
    end
  end
end
