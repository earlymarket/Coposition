require "rails_helper"

RSpec.describe Users::Approvals::DestroyApproval, type: :interactor do
  subject(:destroy_context) { described_class.call(current_user: user, params: { id: friend_approval.id }) }

  let(:user) { create :user }
  let(:friend) { create :user }
  let(:developer) { create :developer }
  let(:friend_approval) do
    Approval.add_friend(user, friend)
    Approval.add_friend(friend, user)
    user.approval_for(friend)
  end
  let(:developer_approval) do
    Approval.add_developer(user, developer)
    user.approval_for(developer)
  end

  describe "call" do
    context "when given valid user arguments" do
      it "succeeds" do
        expect(destroy_context).to be_a_success
      end

      it "provides the approvable type" do
        expect(destroy_context.approvable_type).to eq friend_approval.approvable_type
      end
    end

    context "when given valid developer arguments" do
      subject(:destroy_context) { described_class.call(current_user: user, params: { id: developer_approval.id }) }

      it "succeeds" do
        expect(destroy_context).to be_a_success
      end

      it "provides the approvable type" do
        expect(destroy_context.approvable_type).to eq developer_approval.approvable_type
      end
    end

    context "when approval doesn't exist" do
      subject(:destroy_context) { described_class.call(current_user: user, params: { id: "wrong" }) }

      it "fails" do
        expect(destroy_context).to be_a_failure
      end
    end
  end
end
