require "rails_helper"

RSpec.describe Users::PermissionsController, type: :controller do
  include ControllerMacros

  let(:device) { create :device }
  let(:user) do
    u = create_user
    device.checkins << create(:checkin, device: device)
    u.devices << device
    u
  end
  let(:second_user) { create_user }
  let(:friend) { create :user }
  let(:developer) { create :developer }
  let(:permission) do
    device.developers << developer
    device.permitted_users << friend
    Permission.first
  end

  describe "index" do
    before do
      permission
      request.accept = "text/javascript"
    end

    context "from devices page" do
      it "assigns device and device permissions" do
        get :index, params: { user_id: user.id, device_id: device.id, from: "devices" }
        expect(assigns(:permissions_presenter).device).to eq device
        expect(assigns(:permissions_presenter).permissions).to match_array device.permissions.not_coposition_developers
      end
    end

    context "from apps page" do
      it "assigns developer to permissible and developer devices permissions" do
        get :index, params: { from: "apps", device_id: developer.id, user_id: user.id }
        expect(assigns(:permissions_presenter).permissions).to eq device.permissions
          .where(permissible_id: developer.id).not_coposition_developers
        expect(assigns(:permissions_presenter).permissible).to eq developer
      end
    end
    
    context "from friends page" do
      it "assigns friend as permissible and permissions between devices and friend" do
        get :index, params: { user_id: user.id, device_id: friend.id, from: "friends" }
        expect(assigns(:permissions_presenter).permissible).to eq friend
        expect(assigns(:permissions_presenter).permissions).to eq device.permissions.where(permissible_id: friend.id)
      end
    end
  end

  describe "update" do
    before { request.accept = "text/javascript" }

    it "updates the privilege level, bypass_fogging and bypass_delay attributes" do
      put :update, params: {
        user_id: user.id,
        device_id: device.id,
        id: permission.id,
        from: "devices",
        permission: {
          privilege: "disallowed",
          bypass_fogging: true,
          bypass_delay: true
        }
      }
      expect(Permission.find(permission.id).privilege).to eq "disallowed"
      expect(Permission.find(permission.id).bypass_fogging).to eq true
      expect(Permission.find(permission.id).bypass_delay).to eq true
    end

    it "updates the privilege level and return the correct permission from apps page" do
      put :update, params: {
        user_id: user.id,
        device_id: device.id,
        id: permission.id,
        from: "apps",
        permission: {
          privilege: "complete"
        }
      }
      expect(Permission.find(permission.id).privilege).to eq "complete"
      expect(assigns(:permissions_presenter).permission).to eq Permission.find(permission.id)
    end

    it "fails to update permission user does not control" do
      put :update, params: {
        id: permission.id,
        device_id: device.id,
        permission: {
          bypass_fogging: true
        },
        from: "devices",
        user_id: second_user.id
      }
      expect(response).to redirect_to(root_path)
      expect(Permission.find(permission.id).bypass_fogging).to eq false
    end
  end
end
