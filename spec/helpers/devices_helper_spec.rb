require "rails_helper"

RSpec.describe DevicesHelper, :type => :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }
  let(:device) { FactoryGirl::create(:device) }

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

end
