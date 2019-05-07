require 'rails_helper'

RSpec.describe Developers::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:user) { create :user }
  let(:second_user) { create :user }
  let(:approval) do
    app = create :approval
    app.update(approvable: developer, user: user, approvable_type: 'Developer', status: 'accepted')
    app
  end
  let(:subscription) { create :subscription, event: 'new_approval', subscriber: developer }
  let(:developer_params) { { developer_id: developer.id } }
  let(:approval_create_params) do
    developer_params.merge(approval: { user: user.email, approvable_type: 'Developer' })
  end
  let(:approval_destroy_params) do
    developer_params.merge(id: approval.id)
  end

  describe '#index' do
    it 'should show amount of pending users and show approved users' do
      approval
      get :index, params: developer_params
      expect(assigns(:pending)).to eq developer.pending_approvals
      expect(assigns(:users)).to eq developer.users
    end
  end

  describe '#new' do
    it 'should assign an approval' do
      get :new, params: developer_params
      expect((assigns :approval).class).to eq Approval.new.class
    end
  end

  describe '#create' do
    it 'should create an approval between user and developer' do
      subscription
      post :create, params: approval_create_params
      expect(Approval.where(user: user, approvable: developer, status: 'developer-requested')).to exist
      expect(flash[:notice]).to match 'Successfully sent'
    end

    it 'should fail to create an approval if request exists' do
      approval
      approval_count = Approval.count
      post :create, params: approval_create_params
      expect(flash[:alert]).to match 'Approval already exists'
      expect(Approval.count).to eq approval_count
    end

    it 'should fail to create an approval if user does not exist' do
      approval_create_params[:approval][:user] = 'does not exist'
      approval_count = Approval.count
      post :create, params: approval_create_params
      expect(flash[:alert]).to match 'User does not exist'
      expect(Approval.count).to eq approval_count
    end
  end

  describe '#destroy' do
    it 'should destroy an approval between user and developer' do
      approval
      approval_count = Approval.count
      request.accept = 'text/javascript'
      delete :destroy, params: approval_destroy_params
      expect(Approval.count).to eq approval_count - 1
      expect(user.approval_for(developer).class).to eq NoApproval
    end
  end
end
