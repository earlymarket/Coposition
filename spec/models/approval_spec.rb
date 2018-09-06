require "rails_helper"

RSpec.describe Approval, type: :model do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:developer) { create(:developer) }
  let(:approval) { create(:approval, user: user) }

  describe "#status" do
    context "when status is in the list of allowed" do
      let(:approval) { FactoryBot.build(:approval, user: user) }

      it "is valid approval" do
        expect(approval).to be_valid
      end
    end

    context "when status is not in the list of allowed" do
      let(:approval) { FactoryBot.build(:approval, user: user, status: "random") }

      it "is not valid approval" do
        expect(approval).not_to be_valid
      end
    end
  end

  describe "factory" do
    it "creates a valid checkin" do
      approval = build(:approval)
      expect(approval).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to user" do
      assc = described_class.reflect_on_association(:user)
      expect(assc.macro).to eq :belongs_to
    end

    it "belongs to an approvable" do
      assc = described_class.reflect_on_association(:approvable)
      expect(assc.macro).to eq :belongs_to
    end
  end

  describe "callbacks" do
    context "before_create" do
      let(:new_approval) { build(:approval, user: user) }

      it "fails if user trying to add themselves" do
        new_approval.assign_attributes(approvable: user, approvable_type: "User")
        expect(new_approval.save).to eq false
      end

      it "fails if approval between user and approvable already exists" do
        Approval.add_developer(user, developer)
        new_approval.assign_attributes(approvable: developer, approvable_type: "Developer")
        expect(new_approval.save).to eq false
      end
    end
  end

  describe "public instance methods" do
    context "responds to its methods" do
      it { expect(approval).to respond_to(:approve!) }
    end

    context "approve!" do
      it "updates status and approval date" do
        expect { approval.approve! }.to change { approval.status }
      end

      it "calls approve_devices on approvals user" do
        allow(approval.user).to receive(:approve_devices)
        approval.approve!
        expect(approval.user).to have_received(:approve_devices)
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      %i(add_developer add_friend link accept accept_one_side).each do |method|
        it { expect(Approval).to respond_to(method) }
      end
    end

    context "add_developer" do
      it "calls Approval.link" do
        approval.update(approvable: developer, approvable_type: "Developer")
        allow(Approval).to receive(:link).and_return(approval)
        Approval.add_developer(user, developer)
        expect(Approval).to have_received(:link)
      end

      it "returns the new approval" do
        expect(Approval.add_developer(user, developer)).to be_kind_of(Approval)
      end

      it "accepts the newly created approval request" do
        allow(Approval).to receive(:accept).and_return(approval)
        Approval.add_developer(user, developer)
        expect(Approval).to have_received(:accept)
      end
    end

    context "add_friend" do
      it "calls Approval.link" do
        approval.update(approvable: friend, approvable_type: "User")
        allow(Approval).to receive(:link).and_return(approval)
        Approval.add_friend(user, friend)
        expect(Approval).to have_received(:link)
      end

      it "calls UserMailer" do
        mail = UserMailer.add_user_email(developer, user, false)
        allow(UserMailer).to receive(:add_user_email).and_return(mail)
        Approval.add_friend(user, friend)
        expect(UserMailer).to have_received(:add_user_email)
      end

      it "returns the new approval" do
        expect(Approval.add_friend(user, friend)).to be_kind_of(Approval)
      end

      it "accepts an existing approval request" do
        Approval.add_friend(friend, user)
        allow(Approval).to receive(:accept)
        Approval.add_friend(user, friend)
        expect(Approval).to have_received(:accept)
      end
    end

    context "link" do
      it "calls Approval.create" do
        approval.assign_attributes(approvable: developer, approvable_type: "Developer")
        allow(Approval).to receive(:create).and_return(approval)
        Approval.link(user, developer, "Developer")
        expect(Approval).to have_received(:create)
      end

      it "returns the new approval" do
        expect(Approval.link(user, developer, "Developer")).to be_kind_of(Approval)
      end

      it "creates two approvals if type is User" do
        user
        friend
        expect { Approval.link(user, friend, "User") }.to change { Approval.count }.by(2)
      end
    end

    context "accept" do
      it "calls Approval.accept_one_side" do
        user
        allow(Approval).to receive(:accept_one_side)
        Approval.accept(user, developer, "Developer")
        expect(Approval).to have_received(:accept_one_side)
      end
    end

    context "accept_one_side" do
      before do
        approval.update(approvable: developer, approvable_type: "Developer")
      end

      it "returns an approval" do
        expect(Approval.accept_one_side(user, developer, "Developer")).to be_kind_of Approval
      end

      it "accepts an approval" do
        expect { Approval.accept_one_side(user, developer, "Developer") }.to change { Approval.find(approval.id).status }
      end
    end
  end
end
