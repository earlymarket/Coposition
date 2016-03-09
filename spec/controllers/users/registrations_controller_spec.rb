require 'rails_helper'

RSpec.describe Users::Devise::RegistrationsController, type: :controller do

  include ControllerMacros

  before do
    request.headers['X-Secret-App-Key'] = "this-is-a-mobile-app"
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'create' do
    context 'with a valid email and password' do
      it 'should create a new user' do
        post :create, {
          user: {
            email: "test@email.com",
            password: "password",
            username: "test"
          }
        }
        expect(res_hash[:email]).to eq "test@email.com"
        expect(User.count).to eq 1
      end
    end

    context 'with an invalid email and/or password' do
      it 'should not create a new user' do
        post :create, {
          user: {
            email: "fail-email.com",
            password: "pasword",
            username: "fail"
          }
        }
        expect(res_hash[:email]).to eq ["is invalid"]
        expect(res_hash[:password]).to eq ["is too short (minimum is 8 characters)"]
        expect(User.count).to eq 0
      end
    end
  end

  describe 'destroy' do
    let (:user){ create_user }

    context 'with a password' do
      it 'should destroy the user' do
        user
        delete :destroy, {
          user: {
            password: user.password,
          }
        }
        expect(flash[:notice]).to match "successfully cancelled"
        expect(User.count).to eq 0
      end
    end

    context 'with an invalid password' do
      it 'should not destroy the user' do
        user
        delete :destroy, {
          user: {
            password: "wrong",
          }
        }
        expect(flash[:notice]).to match "invalid"
        expect(User.count).to eq 1
      end
    end
  end

end
