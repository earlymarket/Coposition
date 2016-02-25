require 'rails_helper'

RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user){FactoryGirl::create :user}
  let(:developer){FactoryGirl::create :developer}
  let(:second_user){FactoryGirl::create :user}
  let(:approval) do
    app = FactoryGirl::create :approval
    app.update(user: user, approvable_id: developer.id, approvable_type: 'Developer')
    app
  end
  let(:params) {{ user_id: user.id, format: :json }}
  let(:dev_approval_create_params) do
    params.merge({ approval: { approvable: developer.id, approvable_type: 'Developer' } })
  end
  let(:friend_approval_create_params) do
    params.merge({ approval: { approvable: second_user.id, approvable_type: 'User' } })
  end
  let(:approval_update_params) do
    params.merge({ id: approval.id, approval: { status: 'accepted'} })
  end

  before do
    request.headers["X-Api-Key"] = developer.api_key
  end

  describe "get #index" do
    it "should get a list of a users approvals" do
      Approval.link(user, developer, 'Developer')
      get :index, params
      expect(res_hash.length).to eq 1
      expect(res_hash.first["user_id"]).to eq user.id
    end
  end

  describe "a developer" do

    it "should be able to submit an approval request" do
      post :create, dev_approval_create_params
      expect(Approval.first.status).to eq 'developer-requested'
      expect(user.pending_approvals.count).to be 1
    end

    it "should be not be able to submit another request to same user" do
      Approval.link(user,developer,'Developer')
      post :create, dev_approval_create_params
      expect(Approval.count).to eq 1
      expect(Approval.first.status).to eq 'developer-requested'
      expect(user.pending_approvals.count).to be 1
    end

    it "should be told if the approval is still pending" do
      # No approval
      get :status, params
      expect(res_hash[:approval_status]).to eq "No Approval"

      Approval.link(user,developer,'Developer')
      get :status, params
      expect(res_hash[:approval_status]).to eq "developer-requested"

      Approval.accept(user,developer,'Developer')
      get :status, params
      expect(res_hash[:approval_status]).to eq "accepted"
    end

  end

  describe "a user" do

    before do
      request.headers["X-User-Token"] = user.authentication_token
      request.headers["X-User-Email"] = user.email
    end

    context 'when post to create' do

      it "should be able to create a developer approval" do
        request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
        post :create, dev_approval_create_params
        expect(Approval.last.user).to eq user
        expect(Approval.last.approvable_id).to eq developer.id
        expect(Approval.last.status).to eq 'accepted'
      end

      it "should be able to create a user approval request" do
        post :create, friend_approval_create_params
        expect(Approval.count).to eq 2
        expect(Approval.last.user).to eq second_user
        expect(Approval.last.approvable_id).to eq user.id
        expect(Approval.last.status).to eq 'requested'
      end

      it "should be not be able to submit another request to same user" do
        Approval.link(user,second_user,'User')
        post :create, friend_approval_create_params
        expect(Approval.count).to eq 2
        expect(Approval.first.status).to eq 'pending'
        expect(Approval.last.status).to eq 'requested'
      end

      it "should approve a developer request" do
        request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
        Approval.link(user,developer,'Developer')
        expect(Approval.last.status).to eq 'developer-requested'
        post :create, dev_approval_create_params
        expect(Approval.last.status).to eq 'accepted'
      end

      it "should approve a friend request" do
        request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
        Approval.link(second_user,user,'User')
        expect(Approval.last.status).to eq 'requested'
        post :create, friend_approval_create_params
        expect(Approval.first.status).to eq 'accepted'
        expect(Approval.last.status).to eq 'accepted'
      end
    end

    context 'when posting to #update' do

      it "should be able to approve a developer approval request" do
        put :update, approval_update_params
        expect(user.approved? developer).to be true
      end

      it "should be able to approve a user approval request" do
        Approval.link(user, second_user, 'User')
        expect(user.friends.include? second_user).to be false
        put :update, approval_update_params.merge(id:Approval.first)
        expect(second_user.friends.include? user).to be true
        expect(user.friends.include? second_user).to be true
      end

      it "should not be able to approve if not signed in user" do
        put :update, approval_update_params.merge(user_id:second_user.id)
        expect(res_hash[:message]).to match("Incorrect User")
        expect(response.status).to be 403
        expect(user.approved? developer).to be false
      end

      it "should not be able to approve an approval that does not belong to you" do
        second_user.approvals.create(approvable_id: developer.id)
        put :update, approval_update_params.merge(id:second_user.approvals.last.id)
        expect(res_hash[:message]).to match("does not exist")
        expect(response.status).to be 404
        expect(user.approved? developer).to be false
      end

      it "should be able to reject an approval" do
        approval_update_params[:approval].merge!(status:'rejected')
        put :update, approval_update_params
        expect(Approval.count).to eq 0
        expect(user.approved? developer).to be false
      end

    end
  end
end
