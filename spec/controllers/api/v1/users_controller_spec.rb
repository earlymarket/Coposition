require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include ControllerMacros

  let(:dev) { FactoryGirl::create :developer }
  let(:user) { FactoryGirl::create :user }

  context 'with a correct API key' do
    before do
      request.headers['X-Api-Key'] = dev.api_key
    end

    it 'should reject an unapproved user' do
      get :show, {
        id: user.id,
        format: :json
      }
      expect(response.status).to eq 401
    end

    it 'should assign User.id(:id) to @user if the developer is approved' do
      Approval.link(user,dev,'Developer')
      Approval.accept(user,dev,'Developer')
      get :show, {
        id: user.id,
        format: :json
      }
      expect(assigns(:user)).to eq(User.find(user.id))
    end

  end
end
