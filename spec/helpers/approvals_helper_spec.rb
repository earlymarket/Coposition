require "rails_helper"

RSpec.describe ApprovalsHelper, type: :helper do
  let(:user) do
    user = FactoryGirl.create(:user)
    Approval.add_friend(user, FactoryGirl.create(:user))
    Approval.add_friend(user, FactoryGirl.create(:user))
    user
  end
  let(:friend) { FactoryGirl.create(:user) }
  let(:user_approvals_input) { helper.approvals_input("User") }
  let(:developer_approvals_input) { helper.approvals_input("Developer") }
  let(:checkins) do
    Approval.add_friend(user, friend)
    Approval.add_friend(friend, user)
    friends = user.friends.includes(:devices)
    friends.map do |f|
      {
        userinfo: f.public_info_hash,
        lastCheckin: f.safe_checkin_info_for(permissible: user, action: "last")[0]
      }
    end
  end

  describe "#approvals_approvable_name" do
    it "converts a friend's email if their username is empty" do
      friend = create(:user, username: "")
      expect(friend.email).to include(helper.approvals_approvable_name(friend))
      expect(helper.approvals_approvable_name(friend).length < friend.email.length).to be
    end

    it "gives a company name if passed a developer" do
      dev = create(:developer)
      expect(helper.approvals_approvable_name(dev)).to be dev.company_name
    end

    it "returns an email if passed an email request" do
      req = create(:email_request)
      expect(helper.approvals_approvable_name(req)).to be req.email
    end
  end

  describe "#approvals_add_text" do
    it "return 'add new friend'" do
      expect(helper.approvals_add_text("User")).to match "Add new friend"
    end

    it "returns 'connect new app'" do
      expect(helper.approvals_add_text("Developer")).to match "Connect new app"
    end
  end

  describe "#approvals_new_text" do
    it "return 'enter the email'" do
      expect(helper.approvals_new_text("User")).to match "Enter the email"
    end

    it "returns 'enter the app'" do
      expect(helper.approvals_new_text("Developer")).to match "Enter the App"
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

  describe "#approvals_friends_locater" do
    it "returns nothing if approvable type isn't User" do
      expect(helper.approvals_friends_locator("Developer", friend, checkins)).to eq nil
    end

    it "returns nothing if friend has no checkins" do
      expect(helper.approvals_friends_locator("User", friend, checkins)).to eq nil
    end

    context "with friend checkins" do
      before do
        device = create :device, user_id: friend.id
        create :checkin, device_id: device.id
      end
      
      it "returns a string if approvable type User" do
        expect(helper.approvals_friends_locator("User", friend, checkins)).to be_kind_of String
      end

      it "returns a string containing my_location" do
        expect(helper.approvals_friends_locator("User", friend, checkins)).to match "my_location"
      end
    end
  end
end
