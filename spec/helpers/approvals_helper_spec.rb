require "rails_helper"

RSpec.describe ApprovalsHelper, :type => :helper do
  describe "#approvals_typeahead" do
    it "should return a string" do
      expect(helper.approvals_typeahead('Developer')).to match 'devs'
      expect(helper.approvals_typeahead('User')).to match 'users'
    end
  end
end
