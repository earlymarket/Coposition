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
  let(:developer) { FactoryGirl.create :developer }
  let(:permission) do
    device.developers << developer
    Permission.last
  end

  describe 'update' do
    before do
      request.accept = 'text/javascript'
    end

    it 'should update the privilege level, bypass_fogging and bypass_delay attributes' do
      put :update,
          user_id: user.id,
          device_id: device.id,
          id: permission.id,
          permission: {
            privilege: 'disallowed',
            bypass_fogging: true,
            bypass_delay: true
          }
      expect(Permission.last.privilege).to eq 'disallowed'
      expect(Permission.last.bypass_fogging).to eq true
      expect(Permission.last.bypass_delay).to eq true
    end

    it 'should fail to update permission user does not control' do
      put :update,
          user_id: second_user.id,
          device_id: device.id,
          id: permission.id,
          permission: {
            privilege: 'last_only'
          }
      expect(Permission.last.privilege).to eq 'complete'
      expect(response).to redirect_to(root_path)
    end
  end
end
