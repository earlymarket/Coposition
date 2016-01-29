require 'rails_helper'

RSpec.describe Api::V1::Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:device){FactoryGirl::create :device}
  let(:developer) do
    dev = FactoryGirl::create :developer
    Approval.link(user,dev,'Developer')
    Approval.accept(user,dev,'Developer')
    dev
  end
  let(:user) do
    us = FactoryGirl::create :user
    us.devices << device
    us
  end
  let(:second_user) do
    us = FactoryGirl::create :user
    Approval.link(us,developer,'Developer')
    Approval.accept(us,developer,'Developer')
    us
  end
  let(:approval) { create_approval(user, second_user) }

  before do      
    @checkin = FactoryGirl::build :checkin
    @checkin.uuid = device.uuid
    @checkin.save
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

    it 'should change privilege for developer on a device' do
      expect(device.privilege_for(developer)).to eq 'complete'
      post :switch_privilege, {
        permissible_id: developer.id,
        permissible_type: 'Developer',
        user_id: user.username,
        id: device.id,
        privilege: 'disallowed',
        format: :json
      }
      expect(response.status).to be 200
      expect(device.privilege_for(developer)).to eq 'disallowed'
    end

    it 'should change privilege for user on a device' do
      approval.approve!
      expect(device.privilege_for(second_user)).to eq 'limited'
      post :switch_privilege, {
        permissible_id: second_user.id,
        permissible_type: 'User',
        user_id: user.username,
        id: device.id,
        privilege: 'complete',
        format: :json
      }
      expect(device.privilege_for(second_user)).to eq 'complete'
    end

    it 'should change privilege for developer on all devices' do
      expect(user.devices.last.privilege_for(developer)).to eq 'complete'
      post :switch_all_privileges, {
        permissible_id: developer.id,
        permissible_type: 'Developer',
        user_id: user.username,
        privilege: 'disallowed',
        format: :json
      }
      expect(response.status).to be 200
      expect(user.devices.last.privilege_for(developer)).to eq 'disallowed'
    end

    it 'should not change privilege for developer if user not signed in user' do
      post :switch_all_privileges, {
        permissible_id: developer.id,
        permissible_type: 'Developer',
        user_id: second_user.username,
        privilege: 'disallowed',
        format: :json
      }
      expect(res_hash[:message]).to eq 'Incorrect User'
      expect(response.status).to be 403

    end

    it 'should not change privilege for developer if user does not own device' do
      device = FactoryGirl::create(:device)
      post :switch_privilege, {
        id: device.id,
        permissible_id: developer.id,
        permissible_type: 'Developer',
        user_id: user.username,
        privilege: 'disallowed',
        format: :json
      }
      expect(res_hash[:message]).to eq 'Device does not exist'
      expect(response.status).to be 404
    end

    it 'should not change privilege for developer if user or dev does not exist' do
      post :switch_privilege, {
        id: device.id,
        permissible_id: 99999,
        permissible_type: 'Developer',
        user_id: user.username,
        privilege: 'disallowed',
        format: :json
      }
      expect(res_hash[:message]).to eq 'Developer does not exist'
      expect(response.status).to be 404
      post :switch_privilege, {
        id: device.id,
        permissible_id: 99999,
        permissible_type: 'User',
        user_id: user.username,
        privilege: 'disallowed',
        format: :json
      }
      expect(res_hash[:message]).to eq 'User does not exist'
      expect(response.status).to be 404
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

