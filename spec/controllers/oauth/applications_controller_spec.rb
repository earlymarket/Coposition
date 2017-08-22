require "rails_helper"

RSpec.describe Oauth::ApplicationsController, type: :controller do
  include ControllerMacros

  let!(:developer) { create_developer }
  let(:application_params) do
    {
      doorkeeper_application: {
        name: "New app",
        redirect_uri: "http://example.com/oauth/callback",
        scopes: "public"
      }
    }
  end

  describe "create" do
    it "connects oauth application with developer" do
      post :create, params: application_params
      expect(developer.reload.oauth_application).to be_present
    end
  end
end
