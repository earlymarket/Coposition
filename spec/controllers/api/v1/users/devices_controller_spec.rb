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

  describe "POST" do
    before do
      request.headers["X-User-Token"] = user.authentication_token
      request.headers["X-User-Email"] = user.email
    end

    it 'should change privilege for developer on a device' do
      post :switch_privilege_for_developer, {
        developer_id: developer.id,
        user_id: user.username,
        id: device.id,
        format: :json
      }
      expect(response.status).to be 200
    end

    it 'should change privilege for developer on all devices' do
      post :switch_all_privileges_for_developer, {
        developer_id: developer.id,
        user_id: user.username,
        format: :json
      }
      expect(response.status).to be 200
    end
  end

end