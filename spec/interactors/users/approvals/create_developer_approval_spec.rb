require "rails_helper"

RSpec.describe Users::Approvals::CreateDeveloperApproval, type: :interactor do
  subject(:context) { described_class.call(current_user: user, approvable: developer.company_name) }

  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }

  describe "call" do
    context "when given valid arguments" do
      it "succeeds" do
        expect(context).to be_a_success
      end
    end

    context "when approval already exists" do
      before { Approval.add_developer(user, developer) }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides an alert message" do
        expect(context.error).to eq "Approval/Request exists"
      end
    end

    context "when developer does not exist" do
      subject(:context) { described_class.call(current_user: user, approvable: "madeup@email.com") }

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides a message" do
        expect(context.error).to eq "Developer not found"
      end
    end
  end
end
