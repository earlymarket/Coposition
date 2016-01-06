require 'rails_helper'

RSpec.describe Users::Devise::SessionsController, type: :controller do

  include ControllerMacros
  
  let(:user) { FactoryGirl::create(:user) }

  describe "api authentication" do

    it "should have an auth token" do
      expect(user.authentication_token).to be_an_instance_of String
    end

    it "should be able to sign in" do
      request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app" 
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, 
        user: {
          username: user.username,
          password: user.password
        }, 
        format: :json
      expect(res_hash[:username]).to eq user.username
      expect(res_hash[:authentication_token]).to eq user.authentication_token
    end

    it "should make sure the password is correct" do
      request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, 
        user: {
          username: user.username,
          password: user.password + "incorrect",
        }, 
        format: :json
      
      expect(response.status).to be 401
      expect(res_hash[:username]).to be nil
      expect(res_hash[:authentication_token]).to be nil
    end

  end

end
