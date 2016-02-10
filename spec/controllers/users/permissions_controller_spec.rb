require 'rails_helper'

RSpec.describe Users::PermissionsController, type: :controller do
  include ControllerMacros

  let(:device) { FactoryGirl::create :device }
  let(:user) do
    u = create_user
    u.devices << device
    u
  end
  let(:second_user) { create_user }
  let(:developer) { FactoryGirl::create :developer }
  let(:permission) do
    device.developers << developer
    Permission.last
  end

  describe 'update' do
    it 'should update the privilege level, bypass_fogging and show_history attributes' do
       put :update, {
        user_id: user.id,
        device_id: device.id,
        id: permission.id,
        permission: {
          privilege: 'disallowed',
          bypass_fogging: true,
          show_history: true
        },
      }
      expect(Permission.last.privilege).to eq 'disallowed'
      expect(Permission.last.bypass_fogging).to eq true
      expect(Permission.last.show_history).to eq true
    end

    it 'should fail to update permission user does not control' do
      put :update, {
        user_id: second_user.id,
        device_id: device.id,
        id: permission.id,
        permission: {
          privilege: 'last_only',
        },
      }
      expect(Permission.last.privilege).to eq 'complete'
      expect(response).to redirect_to(root_path)
    end
  end

end