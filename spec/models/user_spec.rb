require 'rails_helper'

RSpec.describe User, type: :model do
  let(:developer) { FactoryGirl.create(:developer) }
  let(:device) { FactoryGirl.create(:device) }
  let(:checkin) { FactoryGirl.create(:checkin, device_id: device.id) }
  let(:user) do
    us = FactoryGirl.create(:user)
    us.devices << device
    us
  end
  let(:empty_user) { FactoryGirl.create(:user) }
  let(:approved) do
    Approval.link(user, developer, 'Developer')
    Approval.link(empty_user, developer, 'Developer')
    Approval.accept(user, developer, 'Developer')
    Approval.accept(empty_user, developer, 'Developer')
  end

  describe 'relationships' do
    it 'should have some devices' do
      expect(user.devices.last).to eq device
    end
  end

  describe 'methods' do
    it 'should create an authentication token on save' do
      user = FactoryGirl.build :user

      expect(user.authentication_token).to be nil
      user.save
      expect(user.authentication_token).to be_an_instance_of String
    end
  end

  describe 'approvals' do
    it 'should approve a developer' do
      expect(user.pending_approvals.count).to be 0
      expect(user.approved?(developer)).to be false

      user.approvals << Approval.create(approvable: developer, approvable_type: 'Developer',
                                        status: 'developer-requested')
      user.save

      expect(user.pending_approvals.count).to be 1
      expect(user.developers.count).to be 0

      Approval.accept(user, developer, 'Developer')
      expect(user.pending_approvals.count).to be 0
      expect(user.developers.count).to be 1
    end

    it 'should approve devices for a developer by default when a developer is approved' do
      user.approvals << Approval.create(approvable: developer, approvable_type: 'Developer',
                                        status: 'developer-requested')
      Approval.accept(user, developer, 'Developer')
      expect(user.devices.first.developers.count).to be 1
      expect(user.devices.first.developers.first).to eq developer
      expect(user.devices.first.permission_for(developer).privilege).to eq 'complete'
    end
  end

  describe 'privileges' do
    context 'between a developer and a user' do
      before do
        Approval.link(user, developer, 'Developer')
        Approval.accept(user, developer, 'Developer')
      end

      it 'should have device privileges by default' do
        expect(user.devices.first.permission_for(developer).privilege).to eq 'complete'
      end
    end
  end

  describe 'slack' do
    it 'should generate a helpful message for slack' do
      expect(user.slack_message).to match "id: #{user.id}, name: #{user.username}"
    end
  end

  describe 'get_user_checkins_for' do
    before do
      checkin
      approved
    end
    context 'user with checkins' do
      it "should return the user's checkins" do
        expect(user.get_user_checkins_for(developer)).to eq [checkin]
      end
    end
    context 'user without checkins' do
      it 'should return no checkins' do
        expect(empty_user.get_user_checkins_for(developer)).to eq Checkin.none
      end
    end
  end
end
