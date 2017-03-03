require "rails_helper"

RSpec.describe User, type: :model do
  let(:device) { FactoryGirl.create(:device) }
  let(:user) do
    us = FactoryGirl.create(:user)
    us.devices << device
    us
  end
  let(:second_user) { FactoryGirl.create(:user) }

  describe "factory" do
    it "creates a valid user" do
      expect(user).to be_valid
    end

    it "is invalid with too short a username" do
      expect(FactoryGirl.build(:user, username: "tom")).not_to be_valid
    end

    it "is invalid with symbols in username" do
      expect(FactoryGirl.build(:user, username: "tom@")).not_to be_valid
    end

    it "is invalid without a unique username" do
      FactoryGirl.create(:user, username: "tommo")
      expect(FactoryGirl.build(:user, username: "tommo")).not_to be_valid
    end
  end

  describe "Associations" do
    it "has many devices" do
      assc = described_class.reflect_on_association(:devices)
      expect(assc.macro).to eq :has_many
    end

    it "has many checkins" do
      assc = described_class.reflect_on_association(:checkins)
      expect(assc.macro).to eq :has_many
    end

    it "has many requests" do
      assc = described_class.reflect_on_association(:requests)
      expect(assc.macro).to eq :has_many
    end

    it "has many approvals" do
      assc = described_class.reflect_on_association(:approvals)
      expect(assc.macro).to eq :has_many
    end

    it "has many subscriptions" do
      assc = described_class.reflect_on_association(:subscriptions)
      expect(assc.macro).to eq :has_many
    end

    it "has many developers" do
      assc = described_class.reflect_on_association(:developers)
      expect(assc.macro).to eq :has_many
    end

    it "has many friends" do
      assc = described_class.reflect_on_association(:friends)
      expect(assc.macro).to eq :has_many
    end

    it "has many permissions" do
      assc = described_class.reflect_on_association(:permissions)
      expect(assc.macro).to eq :has_many
    end

    it "has many permitted_devices" do
      assc = described_class.reflect_on_association(:permitted_devices)
      expect(assc.macro).to eq :has_many
    end
  end

  describe "callbacks" do
    let(:new_user) { FactoryGirl.build(:user) }
    let(:second_user) { FactoryGirl.create(:user) }

    it "generates token before create" do
      allow(new_user).to receive(:generate_token)
      new_user.save
      expect(new_user).to have_received(:generate_token)
    end

    it "doesn't generate token if already exists" do
      allow(new_user).to receive(:generate_token)
      new_user.webhook_key = SecureRandom.uuid
      new_user.save
      expect(new_user).not_to have_received(:generate_token)
    end

    it "approves coposition mobile app after create" do
      allow(new_user).to receive(:approve_coposition_mobile_app)
      new_user.save
      expect(new_user).to have_received(:approve_coposition_mobile_app)
    end
  end

  describe "public instance methods" do
    let(:developer) { FactoryGirl.create(:developer) }
    let(:approve_dev) do
      Approval.link(user, developer, "Developer")
      Approval.accept(user, developer, "Developer")
    end

    context "responds to its methods" do
      it { expect(user).to respond_to(:url_id) }
      it { expect(user).to respond_to(:should_generate_new_friendly_id?) }
      it { expect(user).to respond_to(:approved?) }
      it { expect(user).to respond_to(:request_from?) }
      it { expect(user).to respond_to(:approval_for) }
      it { expect(user).to respond_to(:destroy_permissions_for) }
      it { expect(user).to respond_to(:not_coposition_developers) }
      it { expect(user).to respond_to(:safe_checkin_info) }
      it { expect(user).to respond_to(:filtered_checkins) }
      it { expect(user).to respond_to(:safe_checkin_info_for) }
      it { expect(user).to respond_to(:changed_location?) }
      it { expect(user).to respond_to(:slack_message) }
      it { expect(user).to respond_to(:public_info) }
      it { expect(user).to respond_to(:public_info_hash) }
    end

    context "url_id" do
      it "returns username" do
        expect(user.url_id).to eq(user.username)
      end

      it "returns id" do
        user.username = ""
        expect(user.url_id).to eq(user.id)
      end
    end

    context "should_generate_new_friendly_id?" do
      it "returns true if slug blank" do
        user.slug = nil
        expect(user.should_generate_new_friendly_id?).to eq(true)
      end

      it "returns true if username changed" do
        user.username = "changed"
        expect(user.should_generate_new_friendly_id?).to eq(true)
      end

      it "returns false if slug not blank and username unchanged" do
        expect(user.should_generate_new_friendly_id?).to eq(false)
      end
    end

    context "approved?" do
      it "returns true if permissible is a friend" do
        Approval.add_friend(user, second_user)
        Approval.add_friend(second_user, user)
        expect(user.approved?(second_user)).to eq(true)
      end

      it "returns true if permissible is a developer" do
        approve_dev
        expect(user.approved?(developer)).to eq(true)
      end

      it "returns false if permissible is not a friend or dev" do
        expect(user.approved?(second_user)).to eq(false)
      end
    end

    context "request_from?" do
      it "returns true if permissible sent friend request" do
        Approval.add_friend(second_user, user)
        expect(user.request_from?(second_user)).to eq(true)
      end

      it "returns true if permissible sent develpoer request" do
        Approval.link(user, developer, "Developer")
        expect(user.request_from?(developer)).to eq(true)
      end

      it "returns false if permissible has not sent a request" do
        expect(user.request_from?(second_user)).to eq(false)
      end
    end

    context "approval_for" do
      it "returns approval if one exists" do
        Approval.add_friend(second_user, user)
        expect(user.approval_for(second_user)).to be_kind_of(Approval)
      end

      it "returns NoApproval if permissible has not sent a request" do
        expect(user.approval_for(second_user)).to be_kind_of(NoApproval)
      end
    end

    context "destroy_permissions_for" do
      it "destroys permissions for a friend" do
        Approval.add_friend(second_user, user)
        Approval.add_friend(user, second_user)
        user.destroy_permissions_for(second_user)
        expect(user.devices.last.permissions).to be_empty
      end
    end

    context "not_coposition_developers" do
      it "returns all developers except coposition developers" do
        expect(user.not_coposition_developers).to include(Developer.last)
      end
    end

    context "safe_checkin_info" do
      it "calls device.safe_checkin_info_for if device arg supplied" do
        allow(device).to receive(:safe_checkin_info_for)
        user.safe_checkin_info(device: device)
        expect(device).to have_received(:safe_checkin_info_for)
      end

      it "calls safe_checkin_info_for without device" do
        allow(user).to receive(:safe_checkin_info_for)
        user.safe_checkin_info(device: false)
        expect(user).to have_received(:safe_checkin_info_for)
      end
    end

    context "filtered_checkins" do
      it "calls device.filtered_checkins if device arg supplied" do
        allow(device).to receive(:filtered_checkins)
        user.filtered_checkins(device: device)
        expect(device).to have_received(:filtered_checkins)
      end

      it "calls safe_checkin_info_for without device arg" do
        allow(user).to receive(:safe_checkin_info_for)
        user.filtered_checkins(device: false)
        expect(user).to have_received(:safe_checkin_info_for)
      end
    end

    context "safe_checkin_info_for" do
      before do
        FactoryGirl.create(:checkin, device: device)
        approve_dev
      end

      it "returns paginated checkins if action is index" do
        expect(user.safe_checkin_info_for(action: "index", permissible: developer)).to be_kind_of(WillPaginate::Collection)
      end

      it "returns one checkin if action is last" do
        expect(user.safe_checkin_info_for(action: "last", permissible: developer)).to be_kind_of(Array)
      end
    end

    context "changed_location?" do
      before do
        user.devices.last.checkins.create(lat: 10, lng: 10)
      end

      it "returns true if location" do
        user.devices.last.checkins.create(lat: 20, lng: 20)
        expect(user.changed_location?).to be true
      end

      it "returns false if location not changed " do
        user.devices.last.checkins.create(lat: 10, lng: 10)
        expect(user.changed_location?).to be false
      end
    end

    context "slack_message" do
      it "returns slack message string" do
        msg = "A new user has registered, id: #{user.id}, name: #{user.username}, there are now #{User.count} users."
        expect(user.slack_message).to eq msg
      end
    end

    context "public_info" do
      it "returns a User" do
        expect(user.public_info).to be_kind_of(User)
      end

      it "returns users public info" do
        expect(user.public_info).not_to respond_to(:webhook_key)
      end
    end

    context "public_info_hash" do
      it "returns a hash" do
        expect(user.public_info_hash).to be_kind_of(Hash)
      end

      it "returns users public info" do
        expect(user.public_info).not_to respond_to(:webhook_key)
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      it { expect(user).to respond_to(:public_info) }
    end

    context "self.public_info" do
      it "returns all users public info" do
        expect(User.public_info).to eq(User.all.select(%i(id username slug email)))
      end
    end
  end
end
