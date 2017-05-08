require 'rails_helper'

RSpec.describe Api::V1::DevelopersController, type: :controller do
  include ControllerMacros

  let(:dev) { create :developer }

  before do
    request.headers['X-Api-Key'] = dev.api_key
  end

  describe '#index' do
    it 'should return a list of developers (id, company name, email)' do
      get :index, params: { format: :json }
      expect(res_hash.first.keys).to eq %w(id email company_name)
    end
  end

  describe '#show' do
    it 'should return a developers public info' do
      get :show, params: { id: dev.id, format: :json }
      expect(res_hash.keys).to eq dev.public_info.attributes.keys.map(&:to_sym)
    end
  end
end
