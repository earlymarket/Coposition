require 'rails_helper'

RSpec.describe Api::V1::ConfigsController, type: :controller do
  include ControllerMacros

  let(:developer) do
    developer = FactoryGirl.create :developer
    developer.configs.create(device: device)
    developer
  end
  let(:device) { FactoryGirl.create :device }
  let(:params) { { id: device.id } }
  let(:custom_params) { { type: 'tracker', freq: '1000' } }
  let(:update_params) { params.merge(config: { custom: custom_params }) }

  before do
    request.headers['X-Api-Key'] = developer.api_key
  end

  describe '#index' do
    it 'should return a list of configs which the developer controls' do
      get :index
      expect(res_hash.first['developer_id']).to eq developer.id
    end
  end

  describe '#show' do
    it 'should return a config for the specified device' do
      get :show, params
      expect(res_hash[:device_id]).to eq device.id
    end
  end

  describe '#update' do
    it 'should update a config for the specified device' do
      put :update, update_params
      expect(res_hash[:custom]).to eq custom_params.as_json
    end

    it 'should return a message if config does not exist' do
      put :update, update_params.merge(id: 0)
      expect(res_hash[:error]).to match "Couldn't find Config"
    end
  end
end
