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

  it 'should require a valid API key' do
    get :index, nil
    # No API key supplied => Denied
    expect(response.status).to be 401

    request.headers['X-Api-Key'] = dev.api_key[0..-2]
    get :index
    # API key supplied, but incorrect
    expect(response.status).to be 401

    request.headers['X-Api-Key'] = dev.api_key
    user
    get :index, format: :json
    expect(res_hash.first['username']).to eq user.username
  end

  context 'with a correct API key' do
    before do
      request.headers['X-Api-Key'] = dev.api_key
    end

    it 'should create an unpaid request when Developer authenticates successfully' do
      count = dev.requests.count
      get :index, format: :json
      expect(dev.requests.count).to eq count + 1
      expect(dev.requests.last.paid).to eq false
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
