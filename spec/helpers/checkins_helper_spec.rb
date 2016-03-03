require "rails_helper"

RSpec.describe CheckinsHelper, :type => :helper do
  let(:checkin) { FactoryGirl::create(:checkin) }
  let(:fogged) { FactoryGirl::create(:checkin, fogged: true) }

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
      expect(checkins_static_map_url(checkin)).to match('https://')
      expect(checkins_static_map_url(checkin)).to match(checkin.lat.to_s)
      expect(checkins_static_map_url(checkin)).to match(checkin.lng.to_s)
    end

    it "should also add a marker when checkin is fogged" do
      expect(checkins_static_map_url(checkin)).to match('https://')
      expect(checkins_static_map_url(checkin)).to match(checkin.lat.to_s)
      expect(checkins_static_map_url(checkin)).to match(checkin.lng.to_s)

      expect(checkins_static_map_url(fogged)).to match('markers')
      expect(checkins_static_map_url(fogged)).to match(fogged.lat.to_s)
      expect(checkins_static_map_url(fogged)).to match(fogged.lng.to_s)
    end

  end

end
