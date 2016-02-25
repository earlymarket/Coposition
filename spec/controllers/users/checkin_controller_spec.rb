require 'rails_helper'

RSpec.describe Users::CheckinsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:device) { FactoryGirl::create :device, user_id: user.id } 
  let(:new_user) { create_user }
  let(:checkin) do
    check = FactoryGirl::create(:checkin)
    device.checkins << check
    check
  end

  describe 'GET #show' do
    it 'should assign :id.checkin to @checkin if user owns device which owns checkin' do
      get :show, {
        user_id: user.username,
        device_id: device.id,
        id: checkin.id
      }
      expect(assigns :checkin).to eq(Checkin.find(checkin.id))
    end

    it 'should not assign :id.checkin if user does not own device which owns checkin' do
      user
      get :show, {
        user_id: new_user.username,
        device_id: device.id,
        id: checkin.id
      }
      expect(response).to redirect_to(root_path)
      expect(assigns :checkin).to eq nil
    end
  end

  describe 'DELETE #destroy' do
    it 'should delete all checkins belonging to a device if user owns device' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      delete :destroy, {
        user_id: user.username,
        device_id: device.id,
        id: checkin.id
      }
      expect(device.checkins.count).to eq 0
    end

    it 'should not delete all checkins if user does not own device' do
      count = checkin.device.checkins.count 
      expect(count).to be > 0
      delete :destroy, {
        user_id: new_user.username,
        device_id: device.id,
        id: checkin.id
      }
      expect(response).to redirect_to(root_path)
      expect(device.checkins.count).to eq count
    end
  end
end
