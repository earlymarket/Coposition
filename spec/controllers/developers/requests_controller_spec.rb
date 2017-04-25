require "rails_helper"

RSpec.describe Developers::RequestsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  before do
    req = FactoryGirl.create :request
    developer.requests << req
    req
  end

  describe "PUT #pay" do
    it "changes developers requests paid from false to true" do
      put :pay
      developer.requests.each { |request| expect(request[:paid]).to be true }
      expect(response).to redirect_to(developers_console_path)
    end
  end

  describe "get #index" do
    it "paginates and assigns developers requests to requests" do
      get :index
      expect(assigns(:requests)).to eq developer.requests
    end
  end
end
