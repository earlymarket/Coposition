require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include ControllerMacros

  let(:user) { FactoryGirl::create :user }
  let(:dev) { FactoryGirl::create :developer }

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

  it 'should create an unpaid request when Developer authenticates successfully' do
    count = dev.requests.count
    request.headers['X-Api-Key'] = dev.api_key
    get :index, format: :json
    expect(dev.requests.count).to eq count + 1
    expect(dev.requests.last.paid).to eq false
  end

  it 'should assign User.id(:id) to @user if the developer is approved' do
    dev.request_approval_from user
    user.approve_developer dev
    request.headers['X-Api-Key'] = dev.api_key
    get :show, {
      id: user.id,
      format: :json
    }
    expect(assigns(:user)).to eq(User.find(user.id))
  end

end
