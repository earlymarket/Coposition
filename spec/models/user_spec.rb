require 'rails_helper'

RSpec.describe User, type: :model do
  describe "relationships" do
    it "should have some devices" do
      @user = User.create
      @device = Device.create
      @user.devices << @device
      expect(@user.devices.last).to eq @device 
    end
  end

  describe "approvals" do

    before do
      @user = FactoryGirl::create(:user)
      @developer = FactoryGirl::create(:developer)
    end 

    it "should approve a developer" do
      expect(@user.pending_approvals.count).to be 0

      @user.approvals << Approval.create(developer: @developer)
      @user.save

      expect(@user.pending_approvals.count).to be 1
      expect(@user.approved_developers.count).to be 0

      @user.approve_developer(@developer)

      expect(@user.pending_approvals.count).to be 0
      expect(@user.approved_developers.count).to be 1
    end

    it "should approve devices for a developer by default when a developer is approved" do
      @user.devices << [FactoryGirl::create(:device)]
      @user.approvals << Approval.create(developer: @developer)
      @user.approve_developer(@developer)
      expect(@user.devices.first.developers.count).to be 1
      expect(@user.devices.first.developers.first).to eq @developer
      expect(@user.devices.first.privilege_for(@developer)).to eq "complete"
    end

  end
end
