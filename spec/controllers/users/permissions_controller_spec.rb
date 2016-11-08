require 'rails_helper'

RSpec.describe Users::PermissionsController, type: :controller do
  include ControllerMacros

  let(:device) { FactoryGirl.create :device }
  let(:user) do
    u = create_user
    device.checkins << FactoryGirl.create(:checkin)
    u.devices << device
    u
  end
  let(:second_user) { create_user }
  let(:friend) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
  let(:permission) do
    device.developers << developer
    device.permitted_users << friend
    Permission.first
  end

  describe 'index' do
    before do
      permission
      request.accept = 'text/javascript'
    end

    context 'from devices page' do
      it 'should assign device and device permissions' do
        get :index, params: { user_id: user.id, device_id: device.id, from: 'devices' }
        expect(assigns(:presenter).device).to eq device
        expect(assigns(:presenter).permissions).to match_array device.permissions
      end
    end
    context 'from apps page' do
      it 'should assign developer to permissible and developer devices permissions' do
        get :index, params: { from: 'apps', device_id: developer.id, user_id: user.id }
        expect(assigns(:presenter).permissions).to eq device.permissions.where(permissible_id: developer.id)
        expect(assigns(:presenter).permissible).to eq developer
      end
    end
    context 'from friends page' do
      it 'should assign friend as permissible and permissions between devices and friend' do
        get :index, params: { user_id: user.id, device_id: friend.id, from: 'friends' }
        expect(assigns(:presenter).permissible).to eq friend
        expect(assigns(:presenter).permissions).to eq device.permissions.where(permissible_id: friend.id)
      end
    end
  end

  describe 'update' do
    before { request.accept = 'text/javascript' }

    it 'should update the privilege level, bypass_fogging and bypass_delay attributes' do
      put :update, params: {
        user_id: user.id,
        device_id: device.id,
        id: permission.id,
        from: 'devices',
        permission: {
          privilege: 'disallowed',
          bypass_fogging: true,
          bypass_delay: true
        }
      }
      expect(Permission.find(permission.id).privilege).to eq 'disallowed'
      expect(Permission.find(permission.id).bypass_fogging).to eq true
      expect(Permission.find(permission.id).bypass_delay).to eq true
    end

    it 'should fail to update permission user does not control' do
      put :update, params: {
        user_id: second_user.id,
        device_id: device.id,
        id: permission.id,
        from: 'devices',
        permission: {
          privilege: 'last_only'
        }
      }
      expect(Permission.find(permission.id).privilege).to eq 'last_only'
      expect(response).to redirect_to(root_path)
    end
  end
end
