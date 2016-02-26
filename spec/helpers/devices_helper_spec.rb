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

  describe '#devices_fog_button_text' do
    it "should return a string for the fogging button" do
      expect(helper.devices_fog_button_text(device)).to eq('Fogging is off')
      device.fogged = true
      expect(helper.devices_fog_button_text(device)).to match('Fogging is on')
    end
  end

end
