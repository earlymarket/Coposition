require 'rails_helper'

RSpec.describe Developers::ConsolesController, type: :controller do
  include ControllerMacros

  let(:developer) do
    dev = create_developer
    dev.requests << create(:request)
    dev
  end
  let(:developer_params) { { developer_id: developer.id } }

  describe '#show' do
    it 'should assign requests today and unpaid requests' do
      get :show, params: developer_params
      expect(assigns(:requests_today)).to eq developer.requests.since(1.day.ago).count
      expect(assigns(:unpaid)).to eq developer.requests.where(paid: false).count
    end
  end

  describe '#key' do
    it 'should generate a new api key' do
      request.accept = 'text/javascript'
      post :key, params: developer_params
      expect(assigns(:api_key)).to eq developer.reload.api_key
    end
  end
end
