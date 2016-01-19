require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include ControllerMacros

  let(:device) do
    devi = FactoryGirl::create :device
    3.times do
      checkin = FactoryGirl::build :checkin
      checkin.uuid = devi.uuid
      checkin.save
    end
    devi
  end
  let(:dev) { FactoryGirl::create :developer }
  let(:user) do
    us = FactoryGirl::create :user
    dev.request_approval_from(us)
    us.approve_developer(dev)
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
      dev.request_approval_from user
      user.approve_developer dev
      get :show, {
        id: user.id,
        format: :json
      }
      expect(assigns(:user)).to eq(User.find(user.id))
    end

    it 'should get users last checkin' do
      get :last_checkin, {
        id: user.id,
        format: :json
      }
      expect(res_hash.first['id']).to eq device.id
      expect(res_hash.last['device_id']).to eq device.id
      expect(Checkin.find(res_hash.last['id'])).to eq device.checkins.last
    end

    it 'should get a page of the users checkins' do
      get :all_checkins, {
        id: user.id,
        format: :json
      }
      expect(res_hash.length).to eq 3
      expect(res_hash.first['id']).to eq Checkin.last.id
    end

    it 'should get a list of (developer) requests' do
      get :requests, {
        id: user.id,
        format: :json
      }
      expect(res_hash.first.first['action']).to eq "requests"
    end

    it 'should get the last request related to this user' do
      get :last_request, {
        id: user.id,
        format: :json
      }
      expect(res_hash.first['action']).to eq "last_request"
    end

  end
end
