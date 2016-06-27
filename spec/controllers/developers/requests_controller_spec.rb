require 'rails_helper'

RSpec.describe Developers::RequestsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:request) do
    req = FactoryGirl.create :request
    developer.requests << req
    req
  end

  describe 'PUT #pay' do
    it 'should change developers requests paid from false to true' do
      request
      put :pay
      developer.requests.each { |request| expect(request[:paid]).to be true }
      expect(response).to redirect_to(developers_console_path)
    end
  end

  describe 'get #index' do
    it 'should paginate and assign developers requests to requests' do
      request
      get :index
      expect(assigns(:requests)).to eq developer.requests
    end
  end
end
