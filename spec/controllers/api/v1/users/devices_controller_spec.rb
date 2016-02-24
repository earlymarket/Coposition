require 'rails_helper'

RSpec.describe Api::V1::Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:device){FactoryGirl::create :device}
  let(:developer) do
    dev = FactoryGirl::create :developer
    Approval.link(user,dev,'Developer')
    Approval.accept(user,dev,'Developer')
    Approval.link(second_user,dev,'Developer')
    Approval.accept(second_user,dev,'Developer')
    dev
  end
  let(:user) do
    us = FactoryGirl::create :user
    us.devices << device
    us
  end
  let(:second_user) do
    us = FactoryGirl::create :user
    us.devices << FactoryGirl::create(:device)
    us
  end

  before do
    request.headers["X-Api-Key"] = developer.api_key
    request.headers["X-User-Token"] = user.authentication_token
    request.headers["X-User-Email"] = user.email
  end

  describe "GET" do


    it "should GET a list of devices of a specific user" do
      get :index, user_id: user.username, format: :json
      expect(res_hash.first["id"]).to be device.id
    end

    it "should record the request" do
      expect(developer.requests.count).to be 0
      get :index, user_id: user.username, format: :json
      expect(developer.requests.count).to be 1
    end

    it "should GET information on a specific device for a specific user" do
      get :show, user_id: user.username, id: device.id, format: :json
      expect(res_hash.first["id"]).to be device.id
    end

  end

  describe "PUT" do

    it "should update settings" do
      put :update, { user_id: user.id, id: device.id,  device: { fogged: true }, format: :json }
      expect(res_hash[:fogged]).to eq(true)
      put :update, { user_id: user.id, id: device.id,  device: { fogged: false }, format: :json }
      device.reload
      expect(res_hash[:fogged]).to eq(false)
    end

    it "should reject non-existant device ids" do
      put :update, { user_id: user.id, id: 999999999,  device: { fogged: true }, format: :json }
      expect(response.status).to eq(404)
      expect(res_hash[:message]).to eq('Device does not exist')
    end

    it "should not allow you to update someone elses device" do
      put :update, { user_id: second_user.id, id: second_user.devices.last.id,  device: { fogged: true }, format: :json }
      expect(response.status).to eq(403)
      expect(res_hash[:message]).to eq('User does not own device')
    end
  end

end

