require "rails_helper"

RSpec.describe CheckinsHelper, :type => :helper do
  let(:device) { FactoryGirl::create(:device) }
  let(:checkin) do
    checkin = FactoryGirl::create(:checkin)
    checkin.device = device
    checkin
  end
  let(:fogged) { FactoryGirl::create(:checkin, fogged: true) }

  describe "#checkins_humanize_date" do
    it "should accept a date" do
      expect { helper.checkins_humanize_date(Faker::Date.forward(30)) }.not_to raise_error
    end

    it "should return a string" do
      expect( helper.checkins_humanize_date(Faker::Date.forward(30)).class ).to eq(String)
    end
  end

  describe "#checkins_fogged_address" do
    it "should return nothing if it checkin is not fogged" do
      expect { helper.checkins_fogged_address(checkin) }.not_to raise_error
      expect(helper.checkins_fogged_address(checkin)).to eq(nil)
    end

    it "should return an address if fogged" do
      # Need to check get_data always supplies something in @fogged.address
      expect(helper.checkins_fogged_address(fogged)).to match('Fogged Address:')
    end
  end

  describe "#checkins_static_map_url" do
    it "should return a map url string" do
      expect(checkins_static_map_url(checkin)).to match('http://')
      expect(checkins_static_map_url(checkin)).to match(checkin.lat.to_s)
      expect(checkins_static_map_url(checkin)).to match(checkin.lng.to_s)
    end

    it "should also add a marker when checkin is fogged" do
      expect(checkins_static_map_url(checkin)).to match('http://')
      expect(checkins_static_map_url(checkin)).to match(checkin.lat.to_s)
      expect(checkins_static_map_url(checkin)).to match(checkin.lng.to_s)

      expect(checkins_static_map_url(fogged)).to match('markers')
      expect(checkins_static_map_url(fogged)).to match(fogged.lat.to_s)
      expect(checkins_static_map_url(fogged)).to match(fogged.lng.to_s)
    end

  end

  describe '#checkins_visible_time' do
    it "should return nothing if device is not delayed" do
      expect(helper.checkins_visible_time(checkin)).to eq(nil)
    end

    it "should return a string if device is delayed" do
      device.update(delayed: 10)
      expect(helper.checkins_visible_time(checkin).class).to eq(ActiveSupport::SafeBuffer)
    end
  end

end
