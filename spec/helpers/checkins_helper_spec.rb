require "rails_helper"

RSpec.describe CheckinsHelper, :type => :helper do

  describe "#checkins_fogged_icon" do
    it "returns different icons depending on a boolean input" do
      expect(helper.checkins_fogged_icon(true)).not_to eq(helper.checkins_fogged_icon(false))
      expect(helper.checkins_fogged_icon(true)).to match('icon')
      expect(helper.checkins_fogged_icon(false)).to match('icon')
    end
  end

  describe "#checkins_humanize_date" do
    it "should accept a date" do
      expect { helper.checkins_humanize_date(Faker::Date.forward(30)) }.not_to raise_error
    end

    it "should return a string" do
      expect( helper.checkins_humanize_date(Faker::Date.forward(30)).class ).to eq(String)
    end
  end

  describe "#checkins_fogged_address" do
    let(:fogged) { FactoryGirl::create(:checkin, fogged: true) }
    it "should return nothing if it gets nothing" do
      expect { helper.checkins_fogged_address }.not_to raise_error
      expect(helper.checkins_fogged_address).to eq(nil)
    end

    it "should return an address if fogged" do
      @fogged = fogged
      # Need to check get_data always supplies something in @fogged.address
      expect(helper.checkins_fogged_address).to match('Fogged Address:')
    end
  end

  describe "#checkins_static_map_url" do
    let(:checkin) { FactoryGirl::create(:checkin) }
    let(:fogged) { FactoryGirl::create(:checkin, lat: Faker::Address.latitude, lng: Faker::Address.longitude) }
    it "should return a map url string" do
      @checkin = checkin
      expect(checkins_static_map_url).to match('http://')
      expect(checkins_static_map_url).to match(@checkin.lat.to_s)
      expect(checkins_static_map_url).to match(@checkin.lng.to_s)
    end

    it "should also add a marker when @fogged exists" do
      @checkin = checkin
      @fogged = fogged

      expect(checkins_static_map_url).to match('http://')
      expect(checkins_static_map_url).to match(@checkin.lat.to_s)
      expect(checkins_static_map_url).to match(@checkin.lng.to_s)

      expect(checkins_static_map_url).to match('markers')
      expect(checkins_static_map_url).to match(@fogged.lat.to_s)
      expect(checkins_static_map_url).to match(@fogged.lng.to_s)
    end

  end

end
