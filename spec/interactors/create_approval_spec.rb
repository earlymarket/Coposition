require "rails_helper"

RSpec.describe CreateApproval, type: :interactor do
  subject(:context) { described_class.call(current_user: user, approvable: friend.email) }

  let(:user) { FactoryGirl.create :user }
  let(:friend) { FactoryGirl.create :user }

  describe "call" do
    context "when given valid arguments" do
      it "succeeds" do
        expect(context).to be_a_success
      end

      it "provides a message" do
        expect(context.message).to eq notice: "Friend request sent"
      end

      it "provides a path" do
        expect(context.path).to eq "/users/#{user.id}/friends"
      end
    end

    context "when approval already exists" do
      before { Approval.add_friend(user, friend) }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides an alert message" do
        expect(context.message).to eq alert: "Error: Approval/Request exists"
      end

      it "provides a path" do
        expect(context.path).to eq "/users/#{user.id}/approvals/new?approvable_type=User"
      end
    end

    context "when friend does not exist" do
      subject(:context) { described_class.call(current_user: user, approvable: "madeup@email.com") }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides a message" do
        expect(context.message).to eq notice: "User not signed up with Coposition, invite email sent!"
      end

      it "provides the root path" do
        expect(context.path).to eq "/"
      end
    end
  end
end
