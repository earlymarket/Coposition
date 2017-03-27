require "rails_helper"

RSpec.describe Users::Approvals::RejectApproval, type: :interactor do
  subject(:context) { described_class.call(current_user: user, params: { id: friend_approval.id }) }

  let(:user) { FactoryGirl.create :user }
  let(:friend) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
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
        expect(context).to be_a_success
      end

      it "provides the approvable type" do
        expect(context.approvable_type).to eq friend_approval.approvable_type
      end
    end

    context "when given valid developer arguments" do
      subject(:context) { described_class.call(current_user: user, params: { id: developer_approval.id }) }

      it "succeeds" do
        expect(context).to be_a_success
      end

      it "provides the approvable type" do
        expect(context.approvable_type).to eq developer_approval.approvable_type
      end
    end

    context "when approval doesn't exist" do
      subject(:context) { described_class.call(current_user: user, params: { id: "wrong" }) }

      it "fails" do
        expect(context).to be_a_failure
      end
    end
  end
end
