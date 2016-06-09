require 'rails_helper'

RSpec.describe Developers::ConsolesController, type: :controller do
  include ControllerMacros

  let(:developer) do
    dev = create_developer
    dev.requests << FactoryGirl.create(:request)
    dev
  end
  let(:developer_params) { { developer_id: developer.id } }

  describe '#show' do
    it 'should assign requests today and unpaid requests' do
      get :show, developer_params
      expect(assigns(:requests_today)).to eq developer.requests.recent(1.day.ago).count
      expect(assigns(:unpaid)).to eq developer.requests.where(paid: false).count
    end
  end

  describe '#key' do
    it 'should generate a new api key' do
      request.accept = 'text/javascript'
      get :key, developer_params
      expect(assigns(:uuid)).to eq developer.reload..uuid
    end
  end
end
