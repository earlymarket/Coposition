require 'rails_helper'

RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user){FactoryGirl::create :user}
  let(:developer){FactoryGirl::create :developer}
  let(:second_user){FactoryGirl::create :user}

  before do
    request.headers["X-Api-Key"] = developer.api_key
  end

  describe "a developer" do

    it "should be able to submit an approval request" do
      post :create, {
        user_id: user.id,
        approval: {
          approvable: developer.id,
          approvable_type: 'Developer'
        },
        format: :json
      }
      expect(Approval.first.status).to eq 'developer-requested'
      expect(user.pending_approvals.count).to be 1
    end

    it "should be not be able to submit another request to same user" do
      Approval.link(user,developer,'Developer')
      post :create, {
        user_id: user.id,
        approval: {
          approvable: developer.id,
          approvable_type: 'Developer'
        },
        format: :json
      }
      expect(Approval.count).to eq 1
      expect(Approval.first.status).to eq 'developer-requested'
      expect(user.pending_approvals.count).to be 1
    end

    it "should be told if the approval is still pending" do
      # No approval
      get :status, user_id: user.username, format: :json
      expect(res_hash[:approval_status]).to be nil

      Approval.link(user,developer,'Developer')
      get :status, user_id: user.username, format: :json
      expect(res_hash[:approval_status]).to eq "developer-requested"

      Approval.accept(user,developer,'Developer')
      get :status, user_id: user.username, format: :json
      expect(res_hash[:approval_status]).to eq "accepted"
    end

  end

  describe "a user" do

    let(:approval) do
      approval = FactoryGirl::create :approval
      approval.approvable_id = developer.id
      approval.approvable_type = 'Developer'
      approval.user = user
      approval.save
      approval
    end

    before do
      request.headers["X-User-Token"] = user.authentication_token
      request.headers["X-User-Email"] = user.email
    end

    context 'when post to create' do

      it "should be able to create a developer approval" do
        request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
        post :create, {
          user_id: user.id,
          approval: {
            approvable: developer.id,
            approvable_type: 'Developer'
          },
          format: :json
        }
        expect(Approval.last.user).to eq user
        expect(Approval.last.approvable_id).to eq developer.id
        expect(Approval.last.status).to eq 'accepted'
      end

      it "should be able to create a user approval request" do
        post :create, {
          user_id: user.id,
          approval: {
            approvable: second_user.id,
            approvable_type: 'User'
          },
          format: :json
        }
        expect(Approval.count).to eq 2
        expect(Approval.last.user).to eq second_user
        expect(Approval.last.approvable_id).to eq user.id
        expect(Approval.last.status).to eq 'requested'
      end

      it "should be not be able to submit another request to same user" do
        Approval.link(user,second_user,'User')
        post :create, {
          user_id: user.id,
          approval: {
            approvable: second_user.id,
            approvable_type: 'User'
          },
          format: :json
        }
        expect(Approval.count).to eq 2
        expect(Approval.first.status).to eq 'pending'
        expect(Approval.last.status).to eq 'requested'
      end

      it "should approve a developer request" do
        request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
        Approval.link(user,developer,'Developer')
        expect(Approval.last.status).to eq 'developer-requested'
        post :create, {
          user_id: user.id,
          approval: {
            approvable: developer.id,
            approvable_type: 'Developer'
          },
          format: :json
        }
        expect(Approval.last.status).to eq 'accepted'
      end

      it "should approve a friend request" do
        request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
        Approval.link(second_user,user,'User')
        expect(Approval.last.status).to eq 'requested'
        post :create, {
          user_id: user.id,
          approval: {
            approvable: second_user.id,
            approvable_type: 'User'
          },
          format: :json
        }
        expect(Approval.first.status).to eq 'accepted'
        expect(Approval.last.status).to eq 'accepted'
      end
    end

    context 'when posting to #update' do

      it "should be able to approve a developer approval request" do
        approval
        put :update, {
          user_id: user.id,
          id: approval.id,
          approval: {
            status: 'accepted'
          },
          format: :json
        }
        expect(user.approved? developer).to be true
      end

      it "should be able to approve a user approval request" do
        Approval.link(user, second_user, 'User')
        expect(user.friends.include? second_user).to be false
        put :update, {
          user_id: user.id,
          id: Approval.first,
          approval: {
            status: 'accepted'
          },
          format: :json
        }
        expect(second_user.friends.include? user).to be true
        expect(user.friends.include? second_user).to be true
      end

      it "should not be able to approve another users approval (user_id)" do
        second_user.approvals.create(approvable_id: developer.id)
        approval
        put :update, {
          user_id: second_user.id,
          id: approval.id,
          approval: {
            status: 'accepted'
          },
          format: :json
        }
        expect(response.status).to be 403
        expect(user.approved? developer).to be false
      end

      it "should not be able to approve an approval that does not exist/does not belong (approval_id)" do
        second_user.approvals.create(approvable_id: developer.id)
        approval
        put :update, {
          user_id: user.id,
          id: second_user.approvals.last.id,
          approval: {
            status: 'accepted'
          },
          format: :json
        }
        expect(response.status).to be 404
        expect(user.approved? developer).to be false
      end

      it "should be able to reject an approval" do
        approval
        put :update, {
          user_id: user.id,
          id: approval.id,
          approval: {
            status: 'rejected'
          },
          format: :json
        }
        expect(Approval.count).to eq 0
        expect(user.approved? developer).to be false
      end

    end
  end
end
