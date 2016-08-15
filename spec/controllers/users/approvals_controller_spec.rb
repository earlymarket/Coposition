require 'rails_helper'

RSpec.describe Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user) do
    user = create_user
    user.devices << FactoryGirl.create(:device)
    user
  end
  let(:friend) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
  let(:approval) do
    app = FactoryGirl.create :approval
    app.update(user: user)
    app.save
    app
  end
  let(:approval_two) do
    app = FactoryGirl.create :approval
    app.update(user: friend)
    app.save
    app
  end
  let(:user_params) { { user_id: user.id } }
  let(:friend_approval_create_params) do
    user_params.merge(approval: { approvable: friend.email, approvable_type: 'User' })
  end
  let(:approve_reject_params) { user_params.merge(id: approval.id) }
  let(:invite_params) do
    user_params.merge(invite: '', approval: { approvable: 'new@email.com', approvable_type: 'User' })
  end

  describe 'GET #new' do
    it 'should assign an empty approval' do
      get :new, params: user_params
      expect((assigns :approval).model_name).to match 'Approval'
    end
  end

  describe 'POST #create' do
    context 'when adding a friend' do
      it 'should create a pending approval, friend request and send an email' do
        count = ActionMailer::Base.deliveries.count
        approval_count = Approval.where(approvable_type: 'User').count
        post :create, params: friend_approval_create_params
        expect(ActionMailer::Base.deliveries.count).to be(count + 1)
        expect(Approval.where(approvable_type: 'User').count).to eq approval_count + 2
        expect(Approval.where(user: user, approvable: friend, status: 'pending')).to exist
        expect(Approval.where(user: friend, approvable: user, status: 'requested')).to exist
      end

      it 'should confirm an existing user friend request' do
        approval.update(status: 'requested', approvable_id: friend.id, approvable_type: 'User')
        approval_two.update(status: 'pending', approvable_id: user.id, approvable_type: 'User')
        post :create, params: friend_approval_create_params
        expect(Approval.where(user: user, approvable: friend, status: 'accepted')).to exist
        expect(Approval.where(user: friend, approvable: user, status: 'accepted')).to exist
      end
    end

    context 'when an incorrect name is provided' do
      it 'should not create or approve an approval if trying to add self' do
        approval_count = Approval.where(approvable_type: 'User').count
        friend_approval_create_params[:approval][:approvable] = user.email
        post :create, params: friend_approval_create_params
        expect(flash[:alert]).to match 'Adding self'
        expect(Approval.where(approvable_type: 'User').count).to eq approval_count
      end

      it 'should not create/approve if trying to add an exisiting friend' do
        approval.update(status: 'accepted', approvable_id: friend.id, approvable_type: 'User')
        approval_two.update(status: 'accepted', approvable_id: user.id, approvable_type: 'User')
        approval_count = Approval.count
        post :create, params: friend_approval_create_params
        expect(flash[:alert]).to match 'exists'
        expect(Approval.count).to eq approval_count
      end
    end

    context 'when inviting a user' do
      it 'should send an email to the address provided' do
        count = ActionMailer::Base.deliveries.count
        post :create, params: invite_params
        expect(ActionMailer::Base.deliveries.count).to be(count + 1)
      end
    end
  end

  describe 'GET #apps' do
    it 'should assign current users apps, devices, pending' do
      approval.update(status: 'accepted', approvable_id: developer.id, approvable_type: 'Developer')
      get :apps, params: user_params
      expect(assigns(:presenter).approved).to eq user.developers
      expect(assigns(:presenter).devices).to eq user.devices
      expect(assigns(:presenter).pending).to eq user.developer_requests
    end
  end

  describe 'GET #friends' do
    it 'should assign current users friends' do
      approval_two.update(user: user, status: 'accepted', approvable_id: friend.id, approvable_type: 'User')
      get :friends, params: user_params
      expect(assigns(:presenter).pending).to eq user.friend_requests
      expect(assigns(:presenter).approved).to eq user.friends
      expect(assigns(:presenter).devices).to eq user.devices
    end
  end

  describe 'POST #approve' do
    it 'should approve a developer approval request' do
      approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
      request.accept = 'text/javascript'
      post :approve, params: approve_reject_params
      expect(Approval.last.status).to eq 'accepted'
    end
  end

  describe 'POST #reject' do
    it 'should reject and destroy a developer approval request' do
      approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
      approval_count = Approval.count
      request.accept = 'text/javascript'
      post :reject, params: approve_reject_params
      expect(Approval.count).to eq approval_count - 1
    end

    it 'should reject and destroy both sides of a user approval' do
      approval.update(status: 'requested', approvable_id: friend.id, approvable_type: 'User')
      approval_two.update(status: 'pending', approvable_id: user.id, approvable_type: 'User')
      approval_count = Approval.count
      request.accept = 'text/javascript'
      post :reject, params: approve_reject_params
      expect(Approval.count).to eq approval_count - 2
    end

    it 'should destroy an existing approval and permissions' do
      approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
      approval.approve!
      permission_count = Permission.count
      request.accept = 'text/javascript'
      post :reject, params: approve_reject_params
      expect(Permission.count).to eq permission_count - 1
    end
  end
end
