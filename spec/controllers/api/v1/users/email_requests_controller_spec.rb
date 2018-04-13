require "rails_helper"

RSpec.describe Api::V1::Users::EmailRequestsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:developer) { create :developer }
  let(:email_request) { create :email_request, user_id: user.id }
  let(:params) { { user_id: user.id } }
  let(:destroy_params) { params.merge(id: email_request.id) }

  before do
    request.headers["X-Api-Key"] = developer.api_key
    request.headers["X-User-Token"] = user.authentication_token
    request.headers["X-User-Email"] = user.email
  end

  describe "get #index" do
    it "gets a list of a users email requests" do
      email_request
      get :index, params: params
      expect(res_hash[0]["id"]).to eq EmailRequest.where(user: user)[0].id
    end

    it "gets a list of a users email requests" do
      email_request
      get :index, params: params
      expect(res_hash.length).to eq EmailRequest.where(user: user).count
    end
  end

  describe "DELETE #destroy" do
    it "renders message" do
      delete :destroy, params: destroy_params
      expect(res_hash[:message]).to eq "Email request destroyed"
    end

    it "returns response with status 200" do
      delete :destroy, params: destroy_params
      expect(response.status).to be 200
    end

    it "destroys the email request" do
      email_request
      expect { delete :destroy, params: destroy_params }.to change(EmailRequest, :count).by(-1)
    end
  end
end
