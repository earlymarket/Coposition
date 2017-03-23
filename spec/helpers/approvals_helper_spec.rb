require "rails_helper"

RSpec.describe ApprovalsHelper, type: :helper do
  let(:user) do
    user = FactoryGirl.create(:user)
    user.pending_friends << [FactoryGirl.create(:user), FactoryGirl.create(:user)]
    user
  end
  let(:user_approvals_input) { helper.approvals_input("User") }
  let(:developer_approvals_input) { helper.approvals_input("Developer") }

  describe "#approvals_input" do
    it "assigns placeholder and class key a string" do
      expect(developer_approvals_input[:placeholder]).to match "name"
      expect(user_approvals_input[:placeholder]).to match "email@email.com"
      expect(user_approvals_input[:class]).to match "validate"
      expect(developer_approvals_input[:class]).to match "devs_typeahead"
    end
  end

  describe "#approvals_pending_friends" do
    it "returns a string with emails of users who requests sent to" do
      expect(helper.approvals_pending_friends(user)).to be_kind_of(String)
      expect(helper.approvals_pending_friends(user)).to_not match ","
      expect(helper.approvals_pending_friends(user)).to match "and"
    end

    it "uses commas if the user has more than 2 pending friends" do
      friend = FactoryGirl.create(:user)
      user.pending_friends << friend
      expect(helper.approvals_pending_friends(user)).to match ","
      expect(helper.approvals_pending_friends(user)).to match "and"
      expect(helper.approvals_pending_friends(user)).to match friend.email
    end
  end

  describe "#approvals_approvable_name" do
    it "converts a friend's email if their username is empty" do
      friend = FactoryGirl.create(:user, username: "")
      expect(friend.email).to include(helper.approvals_approvable_name(friend))
      expect(helper.approvals_approvable_name(friend).length < friend.email.length).to be
    end

    it "gives a company name if passed a developer" do
      dev = FactoryGirl.create(:developer)
      expect(helper.approvals_approvable_name(dev)).to be dev.company_name
    end
  end

  describe "#approvals_friends_device_link" do
    it "adds a link if approvable_type is User" do
      allow(helper).to receive(:current_user) { user }
      expect(helper.approvals_friends_device_link("User", user) { "blah" }).to match "<a href"
      expect(helper.approvals_friends_device_link("User", user) { "blah" }).to match "blah"
    end

    it "doesn't add a link if approvable_type is Developer" do
      expect(helper.approvals_friends_device_link("Developer", user) { "blah" }).to_not match "<a href"
      expect(helper.approvals_friends_device_link("Developer", user) { "blah" }).to match "blah"
    end
  end

  describe "#create_approval_url" do
    it "returns a different path for user approvals and for developers" do
      allow(helper).to receive(:current_user) { user }
      expect(helper.create_approval_url("Developer")).to match "create_dev_approvals"
      expect(helper.create_approval_url("User")).to match "approvals"
    end
  end

  describe "#approvals_friends_locater" do
    it "returns nothing if approvable type isn't User" do
      expect(helper.approvals_friends_locator("Developer", user)).to eq nil
    end

    it "returns a string if approvable type User" do
      expect(helper.approvals_friends_locator("User", user)).to be_kind_of String
    end

    it "returns a string containing my_location" do
      expect(helper.approvals_friends_locator("User", user)).to match "my_location"
    end
  end
end
