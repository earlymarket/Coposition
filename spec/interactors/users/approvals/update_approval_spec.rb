require "rails_helper"

RSpec.describe Users::Approvals::UpdateApproval, type: :interactor do
  subject(:update_context) { described_class.call(current_user: user, params: { id: friend_approval.id }) }

  let(:user) { create :user }
  let(:friend) { create :user }
  let(:developer) { create :developer }
  let(:friend_approval) do
    Approval.add_friend(user, friend)
    user.approval_for(friend)
  end
  let(:developer_approval) do
    Approval.link(user, developer, "Developer")
    user.approval_for(developer)
  end

  describe "call" do
    context "when given valid user arguments" do
      it "succeeds" do
        expect(update_context).to be_a_success
      end

      it "provides the approval" do
        expect(update_context.approval).to eq friend_approval
      end

      it "provides the approvable type" do
        expect(update_context.approvable_type).to eq friend_approval.approvable_type
      end

      it "provides the approvable" do
        expect(update_context.approvable).to eq friend_approval.approvable
      end
    end

    context "when given valid developer arguments" do
      subject(:update_context) { described_class.call(current_user: user, params: { id: developer_approval.id }) }

      it "succeeds" do
        expect(update_context).to be_a_success
      end
    end

    context "when approval doesn't exist" do
      subject(:update_context) { described_class.call(current_user: user, params: { id: "wrong" }) }

      it "fails" do
        expect(update_context).to be_a_failure
      end
    end
  end
end
