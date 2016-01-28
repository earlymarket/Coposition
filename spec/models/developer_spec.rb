require 'rails_helper'

RSpec.describe Developer, type: :model do

  let(:user) { FactoryGirl::create(:user) }
  let(:developer) { FactoryGirl::create(:developer) }

  describe "approvals" do

    it "should ask for approval" do
      expect(developer.pending_approvals.count).to be 0
      expect(developer.users.count).to be 0

      Approval.link(user.id,developer.id,'Developer')

      expect(developer.pending_approvals.count).to be 1
      expect(developer.users.count).to be 0

      Approval.accept(user.id,developer.id,'Developer')

      expect(developer.pending_approvals.count).to be 0
      expect(developer.users.count).to be 1
    end
  end

end