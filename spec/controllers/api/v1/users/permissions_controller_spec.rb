require 'rails_helper'

RSpec.describe Api::V1::Users::PermissionsController, type: :controller do
  include ControllerMacros
  let(:device) { FactoryGirl::create :device }
  let(:second_device) { FactoryGirl::create :device }
  let(:user) do
    u = FactoryGirl::create :user
    u.devices << device
    u
  end
  let(:second_user) { FactoryGirl::create :user }
  let(:developer) { FactoryGirl::create :developer }
  let(:permission) do
    device.permitted_users << second_user
    device.developers << developer
    Permission.last
  end

  before do
    request.headers["X-User-Token"] = user.authentication_token
    request.headers["X-User-Email"] = user.email
  end

  describe 'update' do
    it 'should update the privilege level, bypass_fogging and show_history attributes' do
       put :update, {
        id: permission.id,
        device_id: device.id,
        user_id: user.id,
        permission: {
          privilege: 'last_only',
        },
      }
      expect(res_hash[:privilege]).to eq 'last_only'
    end

    it 'should fail to update permission if user does not own permission' do
      request.headers["X-User-Token"] = second_user.authentication_token
      request.headers["X-User-Email"] = second_user.email
      put :update, {
        user_id: second_user.id,
        device_id: device.id,
        id: permission.id,
      }
      expect(response.status).to be 403
      expect(res_hash[:message]).to eq 'You do not control that permission'
    end
  end

  describe 'update_all' do
    it "should update all the permissions on a device" do
      permission
      put :update_all, {
        device_id: device.id,
        user_id: user.id,
        permission: {
          privilege: 1,
        },
      }
      expect(res_hash.count).to eq 2
      expect(res_hash.all? { |permission| permission["privilege"] == "last_only" }).to eq true
    end

    it "should fail to update if user does not own device" do
      put :update_all, {
        device_id: second_device.id,
        user_id: user.id,
      }
      expect(res_hash[:message]).to eq 'You do not control that device'
    end
  end
end
