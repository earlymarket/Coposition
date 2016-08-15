require 'rails_helper'

RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
  let(:second_user) { FactoryGirl.create :user }
  let(:apprvl) { FactoryGirl.create(:approval, user: user, approvable_id: developer.id, approvable_type: 'Developer') }

  let(:params) { { user_id: user.id, format: :json } }
  let(:dev_approval_create_params) do
    params.merge(approval: { approvable: developer.id, approvable_type: 'Developer' })
  end
  let(:friend_approval_create_params) do
    params.merge(approval: { approvable: second_user.id, approvable_type: 'User' })
  end
  let(:approval_destroy_params) { params.merge(id: apprvl.id) }
  let(:approval_update_params) { approval_destroy_params.merge(approval: { status: 'accepted' }) }

  before do
    request.headers['X-Api-Key'] = developer.api_key
  end

  describe 'a developer' do
    it 'should be able to submit an approval request' do
      post :create, params: dev_approval_create_params
      expect(Approval.where(user: user, approvable: developer, status: 'developer-requested')).to exist
      expect(user.pending_approvals.count).to be 1
    end

    it 'should be not be able to submit another request to same user' do
      dev_approval_create_params
      Approval.link(user, developer, 'Developer')
      approval_count = Approval.count
      post :create, params: dev_approval_create_params
      expect(Approval.count).to eq approval_count
      expect(user.pending_approvals.count).to be 1
    end

    it 'should be not be able to submit an approval request for another user' do
      friend_approval_create_params
      Approval.link(user, developer, 'Developer')
      approval_count = Approval.count
      post :create, params: friend_approval_create_params
      expect(Approval.count).to be approval_count
      expect(Approval.where(approvable: second_user)).to_not exist
    end

    it 'should be told if the approval is still pending' do
      # No approval
      get :status, params: params
      expect(res_hash[:approval_status]).to eq 'No Approval'

      Approval.link(user, developer, 'Developer')
      get :status, params: params
      expect(res_hash[:approval_status]).to eq 'developer-requested'

      Approval.accept(user, developer, 'Developer')
      get :status, params: params
      expect(res_hash[:approval_status]).to eq 'accepted'
    end
  end

  before do
    request.headers['X-User-Token'] = user.authentication_token
    request.headers['X-User-Email'] = user.email
  end

  describe 'a user' do
    before do
      request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
    end

    context 'when post to create' do
      it 'should be able to create a developer approval' do
        post :create, params: dev_approval_create_params
        expect(Approval.where(approvable: developer, status: 'accepted', user: user)).to exist
      end

      it 'should be able to create a user approval request' do
        friend_approval_create_params
        approval_count = Approval.count
        post :create, params: friend_approval_create_params
        expect(Approval.count).to eq approval_count + 2
        expect(Approval.where(user: second_user, approvable: user, status: 'requested')).to exist
      end

      it 'should be not be able to submit another request to same user' do
        Approval.link(user, second_user, 'User')
        approval_count = Approval.count
        post :create, params: friend_approval_create_params
        expect(Approval.count).to eq approval_count
        expect(Approval.where(approvable_type: 'User', status: 'accepted')).to_not exist
      end

      it 'should approve a developer request' do
        request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
        Approval.link(user, developer, 'Developer')
        expect(Approval.where(user: user, approvable: developer, status: 'developer-requested')).to exist
        post :create, params: dev_approval_create_params
        expect(Approval.where(user: user, approvable: developer, status: 'accepted')).to exist
      end

      it 'should approve a friend request' do
        request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
        Approval.link(second_user, user, 'User')
        expect(Approval.last.status).to eq 'requested'
        post :create, params: friend_approval_create_params
        expect(Approval.first.status).to eq 'accepted'
        expect(Approval.last.status).to eq 'accepted'
      end
    end

    context 'making a request to #update' do
      it 'should be able to approve a developer approval request' do
        put :update, params: approval_update_params
        expect(user.approved?(developer)).to be true
      end

      it 'should be able to approve a user approval request' do
        Approval.link(user, second_user, 'User')
        expect(user.friends.include?(second_user)).to be false
        put :update, params: approval_update_params.merge(id: Approval.find_by(user: user, approvable_type: 'User').id)
        expect(second_user.friends.include?(user)).to be true
        expect(user.friends.include?(second_user)).to be true
      end

      it 'should not be able to approve if not signed in user' do
        put :update, params: approval_update_params.merge(user_id: second_user.id)
        expect(res_hash[:error]).to match('Incorrect User')
        expect(response.status).to be 403
        expect(user.approved?(developer)).to be false
      end

      it 'should not be able to approve an approval that does not belong to you' do
        second_user.approvals.create(approvable_id: developer.id)
        put :update, params: approval_update_params.merge(id: second_user.approvals.last.id)
        expect(res_hash[:error]).to match('does not exist')
        expect(response.status).to be 404
        expect(user.approved?(developer)).to be false
      end
    end

    context 'making a request to #destroy' do
      it 'should be able to reject an approval' do
        approval_destroy_params
        approval_count = Approval.count
        delete :destroy, params: approval_destroy_params
        expect(Approval.count).to eq approval_count - 1
        expect(user.approved?(developer)).to be false
      end
    end
  end

  describe 'get #index' do
    before do
      Approval.link(user, developer, 'Developer')
      Approval.link(user, second_user, 'User')
      Approval.accept(user, second_user, 'User')
    end

    it 'should get a list of a users approvals' do
      get :index, params: params
      expect(res_hash.length).to eq Approval.where(user: user).count
      expect(res_hash.first['user_id']).to eq user.id
    end

    it 'should get a list of a users accepted friend approvals' do
      get :index, params: params.merge(type: 'friends')
      expect(res_hash.length).to eq Approval.where(user: user, approvable_type: 'User').count
      expect(res_hash.first['status']).to eq 'accepted'
      expect(res_hash.first['approvable_type']).to eq 'User'
    end
  end
end
