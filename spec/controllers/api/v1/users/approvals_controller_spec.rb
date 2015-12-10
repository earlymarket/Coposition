require 'rails_helper'

RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
  include ControllerMacros

  describe "a developer" do

    let(:user){FactoryGirl::create :user}
    let(:developer){FactoryGirl::create :developer}

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

end
