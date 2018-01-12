require "rails_helper"

RSpec.describe User, type: :model do
  let(:device) { create(:device) }
  let(:user) do
    us = create(:user)
    us.devices << device
    us
  end
  let(:second_user) { create(:user) }

  describe "factory" do
    it "creates a valid user" do
      expect(user).to be_valid
    end

    it "is invalid with too short a username" do
      expect(build(:user, username: "tom")).not_to be_valid
    end

    it "is invalid with symbols in username" do
      expect(build(:user, username: "tom@")).not_to be_valid
    end

    it "is invalid without a unique username" do
      create(:user, username: "tommo")
      expect(build(:user, username: "tommo")).not_to be_valid
    end
  end

  describe "Associations" do
    %w(devices checkins requests approvals subscriptions developers approved_developers
       complete_developers friends permissions permitted_devices email_requests).each do |asoc|
      it "has many #{asoc}" do
        assc = described_class.reflect_on_association(asoc.to_sym)
        expect(assc.macro).to eq :has_many
      end
    end
  end

  describe "callbacks" do
    let(:new_user) { build(:user) }
    let(:second_user) { create(:user) }

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

    it "creates new friend requests after create if a user has tried to add them" do
      allow(new_user).to receive(:create_pending_requests)
      new_user.save
      expect(new_user).to have_received(:create_pending_requests)
    end
  end

  describe "public instance methods" do
    let(:developer) { create(:developer) }
    let(:approve_dev) do
      approval = Approval.link(user, developer, "Developer")
      Approval.accept(user, developer, "Developer")
      approval.update(status: "complete")
    end

    context "responds to its methods" do
      %i(url_id should_generate_new_friendly_id? approved? request_from? approval_for destroy_permissions_for
         safe_checkin_info filtered_checkins safe_checkin_info_for slack_message public_info public_info_hash
        display_name).each do |method|
        it { expect(user).to respond_to(method) }
      end
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
        create(:checkin, device: device)
        approve_dev
      end

      it "returns paginated checkins if action is index" do
        expect(user.safe_checkin_info_for(action: "index", permissible: developer)).to be_kind_of(WillPaginate::Collection)
      end

      it "returns one checkin if action is last" do
        expect(user.safe_checkin_info_for(action: "last", permissible: developer)).to be_kind_of(Array)
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

    context "display_name" do
      it "converts a user's email if their username is empty" do
        user.update(username: "")
        expect(user.display_name).to eq user.email.split("@").first
      end

      it "returns username if present" do
        expect(user.display_name).to eq user.username
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      it { expect(User).to respond_to(:public_info) }
    end

    context "self.public_info" do
      it "returns all users public info" do
        expect(User.public_info).to eq(User.all.select(%i(id username slug email)))
      end
    end
  end
end
