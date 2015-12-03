require 'rails_helper'

RSpec.describe Users::Devise::SessionsController, type: :controller do

  include ControllerMacros

  describe "api authentication" do
    let(:user) do 
      us = FactoryGirl::build(:user)
      us.password = "12345678"
      us.password_confirmation = "12345678"
      us.save
      us
    end

    it "should have an auth token" do
      expect(user.authentication_token).to be_an_instance_of String
    end

    it "should be able to sign in" do
      request.headers["Secret-app-key"] = "this-is-a-mobile-app" 
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, 
        user: {
          email: user.email,
          password: user.password
        }, 
        format: :json
      
      expect(res_hash[:email]).to eq user.email
      expect(res_hash[:authentication_token]).to eq user.authentication_token
    end

    it "should make sure the secret app key is correct" do
      request.headers["Secret-app-key"] = "NOT-a-mobile-app" 
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, 
        user: {
          email: user.email,
          password: user.password
        }, 
        format: :json
      
      expect(res_hash[:email]).to be nil
      expect(res_hash[:authentication_token]).to be nil
    end

    it "should make sure the password is correct" do
      request.headers["Secret-app-key"] = "this-is-a-mobile-app"
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, 
        user: {
          email: user.email,
          password: user.password + "incorrect",
        }, 
        format: :json
      
      expect(res_hash[:email]).to be nil
      expect(res_hash[:authentication_token]).to be nil
    end


  end

end
