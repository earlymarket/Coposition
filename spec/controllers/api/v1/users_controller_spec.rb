require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include ControllerMacros

  let(:device) { FactoryGirl::create :device }
  let(:dev) { FactoryGirl::create :developer }
  let(:user) do
    us = FactoryGirl::create :user
    Approval.link(us,dev,'Developer')
    Approval.accept(us,dev,'Developer')
    us.devices << device
    us
  end

  context 'with a correct API key' do
    before do
      request.headers['X-Api-Key'] = dev.api_key
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
