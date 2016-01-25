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
      post :create, user_id: user.username, format: :json

      expect(response.status).to be 200
      expect(user.pending_approvals.count).to be 1
    end

    it "should be told if the approval is still pending" do
      # No approval
      get :status, user_id: user.username, format: :json
      expect(res_hash[:approval_status]).to be nil

      developer.request_approval_from user
      get :status, user_id: user.username, format: :json
      expect(res_hash[:approval_status]).to eq "developer-requested"


      user.approve_developer developer
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

    it "should be able to approve an approval" do
      approval
      put :update, {
        user_id: user.id,
        id: approval.id,
        approval: {
          status: 'accepted'
        },
        format: :json
      }
      expect(user.approved_developer? developer).to be true
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
      expect(user.approved_developer? developer).to be false
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
      expect(user.approved_developer? developer).to be false
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
      expect(user.approved_developer? developer).to be false
    end
  end
end
