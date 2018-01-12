require "rails_helper"

RSpec.describe Api::V1::Users::PermissionsController, type: :controller do
  include ControllerMacros

  let(:device) { create :device }
  let(:second_device) { create :device }
  let(:user) do
    u = create :user
    u.devices << device
    u
  end
  let(:second_user) do
    u = create :user
    u.devices << second_device
    u
  end
  let(:developer) { create :developer }
  let(:permission) do
    device.permitted_users << second_user
    device.developers << developer
    Permission.last
  end

  before do
    api_request_headers(developer, user)
  end

  describe "index" do
    it "returns a list of permissions" do
      permission
      get :index, params: { device_id: device.id, user_id: user.id }
      expect(res_hash.length).to eq device.permissions.count
      expect(res_hash.first.keys).to eq(Permission.column_names)
    end

    context "with complete param" do
      it "returns a list of permissions belonging to friends and complete developers" do
        permission
        get :index, params: { device_id: device.id, user_id: user.id, complete: true }
        expect(res_hash.length).to eq device.complete_permissions.count
      end
    end
  end

  describe "update" do
    it "updates the privilege level, bypass_fogging and bypass_delay attributes" do
      put :update, params: {
        permission: {
          bypass_delay: true,
          bypass_fogging: true,
          privilege: "last_only"
        },
        id: permission.id,
        device_id: device.id,
        user_id: user.id
      }
      expect(res_hash[:privilege]).to eq "last_only"
      expect(res_hash[:bypass_fogging]).to eq true
      expect(res_hash[:bypass_delay]).to eq true
    end

    it "fails to update permission if signed in user does not own permission" do
      request.headers["X-User-Token"] = second_user.authentication_token
      request.headers["X-User-Email"] = second_user.email
      put :update, params: {
        user_id: second_user.id,
        device_id: second_device.id,
        id: permission.id
      }
      expect(response.status).to be 403
      expect(res_hash[:error]).to eq "You do not control that permission"
    end
  end

  describe "update_all" do
    it "updates all the permissions on a device" do
      permission
      put :update_all, params: {
        device_id: device.id,
        user_id: user.id,
        permission: {
          privilege: 1
        }
      }
      expect(res_hash.count).to eq 2
      expect(res_hash.all? { |permission| permission["privilege"] == "last_only" }).to eq true
    end

    it "fails to update if user does not own device" do
      put :update_all, params: {
        device_id: second_device.id,
        user_id: user.id
      }
      expect(res_hash[:error]).to eq "You do not control that device"
    end
  end
end
