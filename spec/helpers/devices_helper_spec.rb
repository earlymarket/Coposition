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
        address: "#{Faker::Address.city}, #{Faker::Address.country_code}"
      })
      expect(helper.devices_last_checkin(device)).to match(checkin.address)
    end
  end

  describe "#devices_delay_icon" do
    it "returns different icons depending on a boolean input" do
      expect(helper.devices_delay_icon(true)).not_to eq(helper.devices_delay_icon(false))
      expect(helper.devices_delay_icon(true)).to match('icon')
      expect(helper.devices_delay_icon(false)).to match('icon')
    end
  end

  describe "#devices_published_icon" do
    it "returns different icons on a devices published state" do
      expect(helper.devices_published_icon(device)).not_to eq(helper.devices_published_icon(other))
      expect(helper.devices_published_icon(device)).to match('icon')
      expect(helper.devices_published_icon(other)).to match('icon')
    end
  end

  describe "#devices_published_link" do
    it "return nothing if not published" do
      expect(helper.devices_published_link(device)).to match('')
    end
    it "return a link if device is published" do
      expect(helper.devices_published_link(other)).to be_kind_of(String)
      expect(helper.devices_published_link(other)).to match("publish")
    end
  end

end
