require 'rails_helper'

RSpec.describe Developer, type: :model do

  describe "approvals" do
    before do
      @user = FactoryGirl::create(:user)
      @developer = FactoryGirl::create(:developer)
    end

    it "should ask for approval" do
      expect(@developer.pending_approvals.count).to be 0
      expect(@developer.approved_users.count).to be 0

      @developer.request_approval_from @user

      expect(@developer.pending_approvals.count).to be 1
      expect(@developer.approved_users.count).to be 0

      @user.approve_developer @developer

      expect(@developer.pending_approvals.count).to be 0
      expect(@developer.approved_users.count).to be 1
    end
  end

end