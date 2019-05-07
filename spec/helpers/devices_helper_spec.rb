require "rails_helper"

RSpec.describe DevicesHelper, type: :helper do
  let(:user) { create :user }
  let(:device) { create(:device, user_id: user.id) }
  let(:other) { Device.update(device.id, published: true) }

  before do
    allow(helper).to receive(:current_user) { user }
  end

  describe "#devices_last_checkin" do
    it "returns 'No Checkins found' if a checkin doesn't exist" do
      expect(helper.devices_last_checkin(device)).to match("No Checkins found")
    end

    it "returns the last checkin address if it exists" do
      checkin = create(:checkin, device_id: device.id)
      expect(helper.devices_last_checkin(device)).to include(checkin.address)
    end
  end

  describe "#devices_shared_link" do
    it "returns nothing if not published" do
      expect(helper.devices_shared_link(device)).to be(nil)
    end

    it "returns a string" do
      expect(helper.devices_shared_link(other)).to be_kind_of(String)
    end

    it "returns the path to the shared device if device is published" do
      # http://test.host/users/1/devices/5/shared
      expect(helper.devices_shared_link(other))
        .to match(%r{http://.+/users/#{device.user_id}/devices/#{device.id}/shared*+})
    end
  end

  describe "devices_cloaked_info" do
    it "returns nothing unless argument is true" do
      expect(helper.devices_cloaked_info(false)).to eq nil
    end

    it "returns a string if argument is true" do
      expect(helper.devices_cloaked_info(true)).to be_kind_of String
    end

    it "returns a string stating the device is cloaked if true" do
      expect(helper.devices_cloaked_info(true)).to match "device is cloaked"
    end
  end

  describe "devices_choose_icon" do
    it "returns a string" do
      expect(helper.devices_choose_icon(device, "laptop")).to be_kind_of String
    end

    it "returns a string with active class if icon matches device icon" do
      expect(helper.devices_choose_icon(device, device.icon)).to match "active"
    end

    it "returns a string with choose-icon class if icon doesn't match device icon" do
      expect(helper.devices_choose_icon(device, "desktop")).to match "choose-icon"
    end
  end
end
