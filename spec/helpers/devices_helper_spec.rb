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

  describe '#devices_fog_message' do
    it "should return a string indicating fogging has been updated" do
      expect(helper.devices_fog_message(device)).to match('no longer fogged')
      device.fogged = true
      expect(helper.devices_fog_message(device)).to match('has been fogged')
    end
  end

  describe '#devices_delay_message' do
    it "should return a string indicating delay has changed" do
      expect(helper.devices_delay_message(device)).to match('not timeshifted')
      device.delayed = Faker::Number.between(1, 300)
      expect(helper.devices_delay_message(device)).to match(device.delayed.to_s)
    end
  end

  describe '#devices_fog_button_text' do
    it "should return a string for the fogging button" do
      expect(helper.devices_fog_button_text(device)).to eq('Fog')
      device.fogged = true
      expect(helper.devices_fog_button_text(device)).to match('Fogged')
    end
  end

end
