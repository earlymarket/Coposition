require 'rails_helper'

RSpec.describe Users::CheckinsController, type: :controller do
  include ControllerMacros

  let(:device) do 
    dev = FactoryGirl::create :device, user_id: user.id
    dev.checkins << FactoryGirl::create(:checkin)
    dev
  end
  let(:user) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user.devices << FactoryGirl::create(:device)
    user
  end
  let(:new_user) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end
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
      expect(assigns :checkin).to eq nil
    end
  end

  describe 'DELETE #destroy' do
    it 'should delete all checkins belonging to a device if user owns device' do
      count = device.checkins.count
      expect(count).to be > 0
      delete :destroy, {
        user_id: user.username,
        device_id: device.id,
        id: checkin.id
      }
      expect(device.checkins.count).to eq 0
    end

    it 'should not delete all checkins if user does not own device' do
      user
      checkin
      count = device.checkins.count
      expect(count).to be > 0
      delete :destroy, {
        user_id: new_user.username,
        device_id: device.id,
        id: checkin.id
      }
      expect(device.checkins.count).to eq count
    end
  end
end
