require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  include CityMacros

  let(:user) { FactoryGirl::create(:user) }
  let(:developer) { FactoryGirl::create(:developer) }
  let(:checkin) { FactoryGirl::create(:checkin) }

  describe "#area_name" do
    it "returns a message if there are no near cities" do
      expect(helper.area_name(checkin)).to match("No nearby cities")
    end

    it "returns the name of the nearest city when there is one" do
      create_denhams
      expect(helper.area_name(checkin)).to match("Denham")
    end
  end

  describe "#fogged_icon" do
    it "returns different icons depending on a boolean input" do
      expect(helper.fogged_icon(true)).not_to eq(helper.fogged_icon(false))
      expect(helper.fogged_icon(true)).to match('icon')
      expect(helper.fogged_icon(false)).to match('icon')
    end
  end
end
