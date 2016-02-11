require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  describe "#permissible_title" do

    let(:user) { FactoryGirl::create(:user) }
    let(:developer) { FactoryGirl::create(:developer) }

    it "returns a thumbnail and company name for developers" do
      expect(helper.permissible_title(developer)).to match('missing.png')
      expect(helper.permissible_title(developer)).to match(developer.company_name)
    end

    it "returns the a formatted email for non-developers" do
      expect(helper.permissible_title(user)).to match(user.email)
    end

  end
end
