require 'rails_helper'

RSpec.describe Developers::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:user) { FactoryGirl.create :user }
  let(:second_user) { FactoryGirl.create :user }
  let(:approval) do
    app = FactoryGirl.create :approval
    app.update(approvable: developer, user: user, approvable_type: 'Developer', status: 'accepted')
    app
  end
  let(:developer_params) { { developer_id: developer.id } }
  let(:approval_create_params) do
    developer_params.merge(approval: { user: user.email, approvable_type: 'Developer' })
  end

  describe '#index' do
    it 'should show amount of pending users and show approved users' do
      approval
      get :index, developer_params
      expect(assigns(:pending)).to eq developer.pending_approvals
      expect(assigns(:users)).to eq developer.users
    end
  end

  describe '#new' do
    it 'should assign an approval' do
      get :new, developer_params
      expect((assigns :approval).class).to eq Approval.new.class
    end
  end

  describe '#create' do
    it 'should create an approval between user and developer' do
      post :create, approval_create_params
      expect(Approval.last.approvable_id).to eq developer.id
      expect(Approval.last.status).to eq 'developer-requested'
      expect(Approval.last.user).to eq user
      expect(flash[:notice]).to match 'Successfully sent'
    end

    it 'should fail to create an approval if request exists' do
      approval
      post :create, approval_create_params
      expect(flash[:alert]).to match 'Error creating approval'
      expect(Approval.count).to eq 1
    end

    it 'should fail to create an approval if user does not exist' do
      approval_create_params[:approval][:user] = 'does not exist'
      post :create, approval_create_params
      expect(flash[:alert]).to match 'Error creating approval'
      expect(Approval.count).to eq 0
    end
  end
end
