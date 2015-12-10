require 'rails_helper'

RSpec.describe Api::V1::Users::DevicesController, type: :controller do
  include ControllerMacros


  describe "GET" do

    let(:device){FactoryGirl::create :device}
    let(:developer){FactoryGirl::create :developer}

    let(:user) do
      us = FactoryGirl::create :user
      us.devices << device
      us
    end

    before do
      
      @checkin = FactoryGirl::build :checkin
      @checkin.uuid = device.uuid
      @checkin.save
      developer.request_approval_from(user)
      user.approve_developer(developer)
      request.headers["X-Api-Key"] = developer.api_key
    end



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

    it "should let you know the last checkin for a list of devices if there is one" do
      get :index, user_id: user.username, id: device.id, format: :json
      expect(res_hash.first["last_checkin"]["id"]).to eq @checkin.id
    end

    it "should let you know the last checkin for device if there is one" do
      get :show, user_id: user.username, id: device.id, format: :json
      expect(res_hash.first["last_checkin"]["id"]).to eq @checkin.id
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

end