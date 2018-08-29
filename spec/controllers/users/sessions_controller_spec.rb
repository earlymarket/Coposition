require "rails_helper"

RSpec.describe Users::Devise::SessionsController, type: :controller do
  include ControllerMacros

  let(:user) { create(:user) }
  let(:params) { { user: { email: user.email, password: user.password }, format: :json } }

  describe "api authentication" do
    before do
      request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it "has an auth token" do
      expect(user.authentication_token).to be_an_instance_of String
    end

    it "signs in a user" do
      post :create, params: params
      expect(res_hash[:email]).to eq user.email
      expect(res_hash[:authentication_token]).to eq user.authentication_token
    end

    it "makes sure the password is correct" do
      params[:user][:password] = "incorrect"
      post :create, params: params
      expect(response.status).to be 400
      expect(res_hash[:email]).to be nil
      expect(res_hash[:authentication_token]).to be nil
    end

    it "signs out the user" do
      request.headers["X-User-Token"] = user.authentication_token
      post :destroy, params: params
      expect(res_hash[:message]).to eq "Signed out"
    end

    it "fails with incorrect user token" do
      request.headers["X-User-Token"] = "invalid token"
      post :destroy, params: params
      expect(res_hash[:error]).to eq "Invalid token."
    end

    it "fails with no password" do
      post :create, params: params.delete("password")
      expect(res_hash[:error]).to eq "The request MUST contain the user email and password."
    end
  end
end
