require 'rails_helper'

RSpec.describe Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user) do
    user = create_user
    user.devices << FactoryGirl::create(:device)
    user
  end
  let(:friend){FactoryGirl::create :user}
  let(:developer){FactoryGirl::create :developer}
  let(:approval) do
    app = FactoryGirl::create :approval
    app.update(user: user)
    app.save
    app
  end
  let(:approval_two) do
    app = FactoryGirl::create :approval
    app.update(user: friend)
    app.save
    app
  end

  describe 'POST #create' do
    context 'when adding a developer' do

      it 'should create an accepted approval between user and developer' do
        post :create, {
          user_id: user.id,
          approval: {
            approvable: developer.email,
            approvable_type: 'Developer'
          }
        }
        expect(Approval.last.user).to eq user
        expect(Approval.last.approvable_id).to eq developer.id
        expect(Approval.last.status).to eq 'accepted'
      end

      it 'should confirm an existing developer approval request' do
        approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
        count = Approval.count
        post :create, {
          user_id: user.id,
          approval: {
            approvable: developer.email,
            approvable_type: 'Developer'
          }
        }
        expect(Approval.count).to eq count
        expect(Approval.last).to eq approval
        expect(Approval.last.status).to eq 'accepted'
      end
    end

    context 'when adding a friend' do
      it 'should create a pending approval and a friend request with a user' do
        post :create, {
          user_id: user.id,
          approval: {
            approvable: friend.email,
            approvable_type: 'User'
          }
        }
        expect(Approval.count).to eq 2
        expect(Approval.first.user).to eq user
        expect(Approval.first.approvable_id).to eq friend.id
        expect(Approval.first.status).to eq 'pending'
        expect(Approval.last.status).to eq 'requested'
      end

      it 'should confirm an existing user friend request' do
        approval.update(status: 'requested', approvable_id: friend.id, approvable_type: 'User')
        approval_two.update(status: 'pending', approvable_id: user.id, approvable_type: 'User')
        post :create, {
          user_id: user.id,
          approval: {
            approvable: friend.email,
            approvable_type: 'User'
          }
        }
        expect(Approval.count).to eq 2
        expect(Approval.first.user).to eq user
        expect(Approval.first.approvable_id).to eq friend.id
        expect(Approval.first.status).to eq 'accepted'
        expect(Approval.last.status).to eq 'accepted'
      end
    end

    context 'when an incorrect email is provided' do
      it 'should not create or approve an approval if user/dev doesnt exist' do
        post :create, {
          user_id: user.id,
          approval: {
            approvable: 'does@not.exist',
            approvable_type: 'Developer'
          }
        }
        expect(Approval.count).to eq 0
        expect(flash[:alert]).to eq 'User/Developer not found'
      end
    end
  end

  describe 'GET #index' do
    it 'should assign current users developers, friends, and pending/requests' do
      approval.update(status: 'accepted', approvable_id: developer.id, approvable_type: 'Developer')
      approval_two.update(user: user, status: 'accepted', approvable_id: friend.id, approvable_type: 'User')
      get :index, {
        user_id: user.id
      }
      expect(assigns :friends).to eq user.friends
      expect(assigns :approved_devs).to eq user.developers
      approval.update(status: 'developer-requested')
      approval_two.update(status: 'requested')
      get :index, {
        user_id: user.id
      }
      expect(assigns :friend_requests).to eq user.friend_requests
      expect(assigns :pending_approvals).to eq user.pending_approvals
    end
  end

  describe 'POST #approve' do
    it 'should approve a developer approval request' do
      approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
      request.accept = 'text/javascript'
      post :approve, {
        user_id: user,
        id: approval.id
      }
      expect(Approval.last.status).to eq 'accepted'
    end
  end

  describe 'POST #reject' do
    it 'should reject and destroy a developer approval request' do
      approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
      expect(Approval.count).to eq 1
      request.accept = 'text/javascript'
      post :reject, {
        user_id: user,
        id: approval.id
      }
      expect(Approval.count).to eq 0
    end

    it 'should destroy an existing approval and permissions' do
      approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
      approval.approve!
      expect(Permission.count).to eq 1
      request.accept = 'text/javascript'
      post :reject, {
        user_id: user,
        id: approval.id
      }
      expect(Permission.count).to eq 0
      expect(Approval.count).to eq 0
    end
  end

end
