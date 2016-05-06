require "rails_helper"

RSpec.describe DevicesHelper, :type => :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }
  let(:device) { FactoryGirl::create(:device, user_id: 1) }
  let(:other) { Device.update(device.id, published: true) }

  describe '#devices_last_checkin' do
    it "returns 'No Checkins found' if a checkin doesn't exist" do
      expect(helper.devices_last_checkin(device)).to match('No Checkins found')
    end

    it "returns the last checkin address if it exists" do
      checkin = FactoryGirl::create(:checkin, {
        device_id: device.id,
      })
      expect(helper.devices_last_checkin(device)).to include(checkin.city)
    end
  end

  describe "#devices_delay_icon" do
    it "returns different icons depending on a boolean input" do
      expect(helper.devices_delay_icon(true)).not_to eq(helper.devices_delay_icon(false))
      expect(helper.devices_delay_icon(true)).to match('icon')
      expect(helper.devices_delay_icon(false)).to match('icon')
    end
  end

  describe "#devices_shared_icon" do
    it "returns different icons on a devices published state" do
      expect(helper.devices_shared_icon(device)).not_to eq(helper.devices_shared_icon(other))
      expect(helper.devices_shared_icon(device)).to match('icon')
      expect(helper.devices_shared_icon(other)).to match('icon')
    end
  end

  describe "#devices_access_icon" do
    it "returns an icon" do
      expect(helper.devices_access_icon).to match('icon')
    end
  end

  describe "#devices_shared_link" do
    it "return nothing if not published" do
      expect(helper.devices_shared_link(device)).to be(nil)
    end
    it "return the path to the shared device if device is published" do
      expect(helper.devices_shared_link(other)).to be_kind_of(String)
      # http://test.host/users/1/devices/5/shared
      expect(helper.devices_shared_link(other)).to match(/http:\/\/.+\/users\/#{device.user_id}\/devices\/#{device.id}\/shared*+/)
    end
  end

end
