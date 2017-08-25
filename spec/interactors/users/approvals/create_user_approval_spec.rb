require "rails_helper"

RSpec.describe Users::Approvals::CreateUserApproval, type: :interactor do
  subject(:create_context) { described_class.call(current_user: user, approvable: friend.email) }

  let(:user) { create :user }
  let(:friend) { create :user }

  describe "call" do
    context "when given valid arguments" do
      it "succeeds" do
        expect(create_context).to be_a_success
      end

      it "provides a message" do
        expect(create_context.message).to eq notice: "Friend request sent"
      end

      it "provides a path" do
        expect(create_context.path).to eq "/users/#{user.id}/friends"
      end
    end

    context "when approval already exists" do
      before { Approval.add_friend(user, friend) }

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides an alert message" do
        expect(create_context.message).to eq alert: "Error: Friend request already sent"
      end

      it "provides a path" do
        expect(create_context.path).to eq "/users/#{user.id}/approvals/new?approvable_type=User"
      end
    end

    context "when friend does not exist" do
      subject(:create_context) { described_class.call(current_user: user, approvable: "madeup@email.com") }

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides a message" do
        expect(create_context.message).to eq notice: "User not signed up with Coposition, invite email sent!"
      end

      it "provides the approvals path" do
        expect(create_context.path).to eq "/users/#{user.id}/friends"
      end
    end
  end
end
