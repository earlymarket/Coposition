require 'rails_helper'

RSpec.describe Api::V1::DevelopersController, type: :controller do
  include ControllerMacros

  let(:dev) { FactoryGirl::create :developer }

  context 'with a correct API key' do
    before do
      request.headers['X-Api-Key'] = dev.api_key
    end

    it 'should create an unpaid request when Developer authenticates successfully' do
      count = dev.requests.count
      get :index, format: :json
      expect(dev.requests.count).to eq count + 1
      expect(dev.requests.first.paid).to eq false
    end

    it 'should return a developers public info' do
      get :show, {
        id: dev.id,
        format: :json
      }
      expect(res_hash.keys).to eq dev.public_info.attributes.keys.map(&:to_sym)
    end

  end
end

