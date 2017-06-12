require "rails_helper"

RSpec.describe Developers::Approvals::CreateApproval, type: :interactor do
  subject(:create_context) { described_class.call(developer: developer, params: { user: user.email }) }

  let(:developer) { create :developer }
  let(:user) { create :user }

  describe "call" do
    context "when given valid arguments" do
      it "succeeds" do
        expect(create_context).to be_a_success
      end

      it "provides a message" do
        expect(create_context.notice).to eq "Successfully sent"
      end

      it "provides the approval" do
        expect(create_context.approval).to eq user.approval_for(developer)
      end
    end

    context "when approval already exists" do
      before { Approval.add_developer(user, developer) }

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides an alert message" do
        expect(create_context.alert).to eq "Approval already exists"
      end
    end

    context "when user does not exist" do
      subject(:create_context) { described_class.call(developer: developer, params: { email: developer.email }) }

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides an alert message" do
        expect(create_context.alert).to eq "User does not exist"
      end
    end
  end
end
