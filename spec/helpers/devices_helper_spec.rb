require "rails_helper"

RSpec.describe DevicesHelper, :type => :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }

  describe '#devices_last_checkin' do
    let(:device) { FactoryGirl::create(:device) }
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

  describe '#devices_fog_status' do
    let(:device) { FactoryGirl::create(:device) }
    it "shouldn't return anything if a device isn't fogged" do
      expect(helper.devices_fog_status(device).class).to eq(NilClass)
    end

    it "should return some html if it is fogged" do
      device.fogged = true
      expect(helper.devices_fog_status(device).class).to eq(safebuffer)
    end
  end

  describe '#devices_delay_status' do
    let(:device) { FactoryGirl::create(:device) }
    it "shouldn't return anything if a device isn't delayed" do
    expect(helper.devices_delay_status(device).class).to eq(NilClass)
    end

    it "should return some html with the delay if it is delayed" do
      device.delayed = Faker::Number.between(1, 300)
      expect(helper.devices_delay_status(device).class).to eq(safebuffer)
      expect(helper.devices_delay_status(device)).to match(device.delayed.to_s)
    end
  end

end
