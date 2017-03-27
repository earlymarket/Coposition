require "rails_helper"

RSpec.describe Developers::Approvals::CreateApproval, type: :interactor do
  subject(:context) { described_class.call(developer: developer, params: { user: user.email }) }

  let(:developer) { FactoryGirl.create :developer }
  let(:user) { FactoryGirl.create :user }

  describe "call" do
    context "when given valid arguments" do
      it "succeeds" do
        expect(context).to be_a_success
      end

      it "provides a message" do
        expect(context.notice).to eq "Successfully sent"
      end

      it "provides the approval" do
        expect(context.approval).to eq user.approval_for(developer)
      end
    end

    context "when approval already exists" do
      before { Approval.add_developer(user, developer) }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides an alert message" do
        expect(context.alert).to eq "Approval already exists"
      end
    end

    context "when user does not exist" do
      subject(:context) { described_class.call(developer: developer, params: { email: developer.email }) }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides an alert message" do
        expect(context.alert).to eq "User does not exist"
      end
    end
  end
end