require "rails_helper"

RSpec.describe NoApproval, type: :model do
  subject(:no_approval) { NoApproval.new }

  describe "public class methods" do
    context "responds to its methods" do
      %i(nil? status).each do |method|
        it { is_expected.to respond_to method }
      end
    end

    context "nil?" do
      it "returns true" do
        expect(no_approval.nil?).to be true
      end
    end

    context "status" do
      it "returns 'No Approval'" do
        expect(no_approval.status).to eq "No Approval"
      end
    end
  end
end
