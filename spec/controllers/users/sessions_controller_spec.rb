require 'rails_helper'

RSpec.describe Users::Devise::SessionsController, type: :controller do
  include ControllerMacros

  let(:user) { FactoryGirl.create(:user) }
  let(:params) { { user: { email: user.email, password: user.password }, format: :json } }

  describe 'api authentication' do
    it 'should have an auth token' do
      expect(user.authentication_token).to be_an_instance_of String
    end

    it 'should be able to sign in' do
      request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, params
      expect(res_hash[:email]).to eq user.email
      expect(res_hash[:authentication_token]).to eq user.authentication_token
    end

    it 'should make sure the password is correct' do
      request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
      request.env['devise.mapping'] = Devise.mappings[:user]
      params[:user][:password] = 'incorrect'
      post :create, params
      expect(response.status).to be 400
      expect(res_hash[:email]).to be nil
      expect(res_hash[:authentication_token]).to be nil
    end

    it 'should be able to sign out' do
      request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
      request.headers['X-User-Token'] = user.authentication_token
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :destroy, params
      expect(res_hash[:message]).to eq 'Signed out'
    end

    context 'when incorrect user token or invalid request' do
      it 'should fail' do
        request.headers['X-Secret-App-Key'] = 'this-is-a-mobile-app'
        request.headers['X-User-Token'] = 'invalid token'
        request.env['devise.mapping'] = Devise.mappings[:user]
        post :destroy, params
        expect(res_hash[:error]).to eq 'Invalid token.'
        post :create, params.delete('password')
        expect(res_hash[:error]).to eq 'The request MUST contain the user email and password.'
      end
    end
  end
end
