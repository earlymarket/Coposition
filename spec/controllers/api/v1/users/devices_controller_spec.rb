require 'rails_helper'

RSpec.describe Api::V1::Users::DevicesController, type: :controller do
  include ControllerMacros


  let(:device){FactoryGirl::create :device}
  let(:developer) do
    dev = FactoryGirl::create :developer
    dev.request_approval_from(user)
    user.approve_developer(dev)
    dev
  end

  let(:user) do
    us = FactoryGirl::create :user
    us.devices << device
    us
  end

  before do      
    @checkin = FactoryGirl::build :checkin
    @checkin.uuid = device.uuid
    @checkin.save
    request.headers["X-Api-Key"] = developer.api_key
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

    it "should let you know the last checkin for devices if there is one" do
      req = Proc.new { |loc| get loc, user_id: user.username, id: device.id, format: :json }
      expect = Proc.new { expect(res_hash.first["last_checkin"]["id"]).to eq @checkin.id }
      
      req.call(:index)
      expect.call
      req.call(:show)
      expect.call
    end

    it "should not only return devices for which the developer has permission" do
      device.change_privilege_for developer, "disallowed"
      get :index, user_id: user.username, format: :json
      expect(response.body).to eq "[]"
      expect(response.status).to be 200
    end

    it "should not allow a developer to see a device for which it disallowed" do
      device.change_privilege_for developer, "disallowed"
      get :show, user_id: user.username, id: device.id, format: :json
      expect(response.body).to eq ""
      expect(response.status).to be 401
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


  end

end
