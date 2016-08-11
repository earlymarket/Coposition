require 'rails_helper'

RSpec.describe Api::V1::Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:device) { FactoryGirl.create :device }
  let(:empty_device) { FactoryGirl.create :device }
  let(:developer) do
    dev = FactoryGirl.create :developer
    Approval.link(user, dev, 'Developer')
    Approval.accept(user, dev, 'Developer')
    Approval.link(second_user, dev, 'Developer')
    Approval.accept(second_user, dev, 'Developer')
    dev
  end
  let(:user) do
    us = FactoryGirl.create :user
    us.devices << device
    us
  end
  let(:second_user) do
    us = FactoryGirl.create :user
    us.devices << FactoryGirl.create(:device)
    us
  end
  let(:params) { { params: { user_id: user.id, format: :json } } }
  let(:device_params) { { params: { id: device.id, user_id: user.id, format: :json } } }
  let(:create_params) { { params: { device: { name: 'new' }, user_id: user.id, format: :json } } }
  let(:private_device_info) { %w(uuid fogged delayed) }

  before do
    api_request_headers(developer, user)
  end

  describe 'GET' do
    it 'should GET a list of devices of a specific user' do
      get :index, params
      expect(res_hash.first['id']).to be device.id
    end

    it 'should record the request' do
      expect(developer.requests.count).to be 0
      get :index, params
      expect(developer.requests.count).to be 1
    end

    it 'should return filtered information on a device belonging to a user' do
      get :show, device_params
      expect(res_hash[:data]['id']).to be device.id
      expect(res_hash[:data].keys).to_not include(*private_device_info)
    end

    it 'should return full info if request is from copo app or from developer with control' do
      developer.configs.create(device: device)
      get :show, device_params
      expect(res_hash[:data]['uuid']).to eq device.uuid
      expect(res_hash[:config]['id']).to eq developer.configs.find_by(device: device).id
      expect(res_hash[:data].keys).to include(*private_device_info)
    end
  end

  describe 'POST' do
    it 'should create a device with a UUID provided' do
      create_params[:params][:device][:uuid] = empty_device.uuid
      config_count = developer.configs.count
      post :create, create_params
      expect(developer.configs.count).to be config_count + 1
      expect(res_hash[:data]['user_id']).to be user.id
      expect(res_hash[:data]['uuid']).to eq empty_device.uuid
    end

    it 'should fail to to create a device with a taken UUID' do
      create_params[:params][:device][:uuid] = device.uuid
      count = user.devices.count
      post :create, create_params
      expect(user.devices.count).to be count
      expect(res_hash[:error]).to match 'registered to another user'
    end

    it 'should fail to to create a device with a taken name' do
      create_params[:params][:device][:name] = device.name
      post :create, create_params
      expect(res_hash[:error]).to match device.name
    end
  end

  describe 'PUT' do
    it 'should update settings' do
      device_params[:params][:device] = { fogged: true }
      put :update, device_params
      expect(res_hash[:fogged]).to eq(true)
      device_params[:params][:device] = { fogged: false }
      put :update, device_params
      device.reload
      expect(res_hash[:fogged]).to eq(false)
    end

    it 'should reject non-existant device ids' do
      device_params[:params].merge!(id: 9999999, device: { fogged: true })
      put :update, device_params
      expect(response.status).to eq(404)
      expect(res_hash[:error]).to eq('Device does not exist')
    end

    it 'should not allow you to update someone elses device' do
      put :update, params: {
        user_id: second_user.id,
        id: second_user.devices.last.id,
        device: { fogged: true }, format: :json
      }
      expect(response.status).to eq(403)
      expect(res_hash[:error]).to eq('User does not own device')
    end
  end
end
