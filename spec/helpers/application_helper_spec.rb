require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  include CityMacros

  let(:user) { FactoryGirl::create(:user) }
  let(:developer) { FactoryGirl::create(:developer) }
  let(:checkin) { FactoryGirl::create(:checkin) }

  describe "#permissible_title" do

    it "returns a thumbnail and company name for developers" do
      expect(helper.permissible_title(developer)).to match('missing.png')
      expect(helper.permissible_title(developer)).to match(developer.company_name)
    end

    it "returns the a formatted email for non-developers" do
      expect(helper.permissible_title(user)).to match(user.email)
    end

  end

  describe "#area_name" do
    it "returns a message if there are no near cities" do
      expect(helper.area_name(checkin)).to match("No nearby cities")
    end

    it "returns the name of the nearest city when there is one" do
      create_denhams
      expect(helper.area_name(checkin)).to match("Denham")
    end
  end
end
