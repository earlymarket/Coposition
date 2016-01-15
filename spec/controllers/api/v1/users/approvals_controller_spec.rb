require 'rails_helper'

RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user){FactoryGirl::create :user}
  let(:developer){FactoryGirl::create :developer}

  describe "a developer" do

    before do
      request.headers["X-Api-Key"] = developer.api_key
    end

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
      expect(res_hash[:approval_status]).to be false


      user.approve_developer developer
      get :status, user_id: user.username, format: :json
      expect(res_hash[:approval_status]).to be true
    end

  end

  describe "a user" do
    let(:approval) do 
      approval = FactoryGirl::create :approval
      approval.developer = developer
      approval.user = user
      approval.save
      approval
    end

    before do
      request.headers["X-Api-Key"] = developer.api_key
      request.headers["X-User-Token"] = user.authentication_token
      request.headers["X-User-Email"] = user.email
    end

    it "should be able to approve an approval" do
      approval
      put :update, {
        user_id: user.id,
        id: approval.id,
        approval: {
          approved: true,
          pending: false
        }, 
        format: :json
      }
      expect(user.approved_developer? developer).to be true
    end

    it "should be able to reject an approval" do
      approval
      put :update, {
        user_id: user.id,
        id: approval.id,
        approval: {
          approved: false,
          pending: false
        }, 
        format: :json
      }
      expect(user.approved_developer? developer).to be false
    end
  end
end
