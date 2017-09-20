require "rails_helper"

RSpec.describe Users::Approvals::CreateDeveloperApproval, type: :interactor do
  subject(:create_context) { described_class.call(current_user: user, approvable: developer.company_name) }

  let(:user) { create :user }
  let(:developer) { create :developer }

  describe "call" do
    context "when given valid arguments" do
      it "succeeds" do
        expect(create_context).to be_a_success
      end
    end

    context "when approval already exists" do
      before { Approval.add_developer(user, developer) }

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides an alert message" do
        expect(create_context.error).to eq "App already connected"
      end
    end

    context "when developer does not exist" do
      subject(:create_context) { described_class.call(current_user: user, approvable: "madeup@email.com") }

      it "fails" do
        expect(create_context).to be_a_failure
      end

      it "provides a message" do
        expect(create_context.error).to eq "Developer not found"
      end
    end
  end
end
