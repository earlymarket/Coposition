require 'rails_helper'

RSpec.describe Users::CheckinsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:device) { FactoryGirl.create :device, user_id: user.id }
  let(:new_user) { create_user }
  let(:checkin) { FactoryGirl.create :checkin, device: device }
  let(:params) { { user_id: user.username, device_id: device.id, id: checkin.id } }

  describe 'GET #new' do
    it 'should assign a device with a matching :device_id to @device and a new checkin to @checkin' do
      get :new, params: params
      expect(assigns(:checkin)).to be_a_new(Checkin)
      expect(assigns(:device)).to eq(Device.find(device.id))
    end
  end

  describe 'POST #create' do
    it 'should assign a device, create a new checkin and assign it to @checkin' do
      checkin
      count = device.checkins.count
      request.accept = 'text/javascript'
      post :create, params: {
        user_id: user.username,
        device_id: device.id,
        checkin: {
          lat: checkin.lat,
          lng: checkin.lng
        }
      }
      expect(assigns(:device)).to eq(Device.find(device.id))
      expect(device.checkins.count).to eq count + 1
      expect(assigns(:checkin)).to eq(device.checkins.first)
    end
  end

  describe 'GET #show' do
    it 'should assign :id.checkin to @checkin if user owns device which owns checkin' do
      request.accept = 'text/javascript'
      get :show, params: params
      expect(assigns(:checkin)).to eq(Checkin.find(checkin.id))
    end

    it 'should not assign :id.checkin if user does not own device which owns checkin' do
      user
      request.accept = 'text/javascript'
      get :show, params: params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(assigns(:checkin)).to eq nil
    end
  end

  describe 'PUT #update' do
    it 'should switch fogging' do
      device.update(fogged: false)
      checkin.update(fogged: false)
      request.accept = 'text/javascript'
      put :update, params: params
      checkin.reload
      expect(checkin.fogged).to be true
      expect(checkin.output_lat).to be checkin.fogged_lat
      put :update, params: params
      checkin.reload
      expect(checkin.fogged).to be false
      expect(checkin.output_lat).to be checkin.lat
    end
  end

  describe 'DELETE #destroy_all' do
    it 'should delete all checkins belonging to a device if user owns device' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      delete :destroy_all, params: {
        user_id: user.username,
        device_id: device.id
      }
      expect(device.checkins.count).to eq 0
    end

    it 'should not delete all checkins if user does not own device' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      delete :destroy_all, params: {
        user_id: new_user.username,
        device_id: device.id
      }
      expect(response).to redirect_to(root_path)
      expect(device.checkins.count).to eq count
    end
  end

  describe 'DELETE #destroy' do
    it 'should delete a checkin by id' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      request.accept = 'text/javascript'
      delete :destroy, params: params
      expect(device.checkins.count).to eq(count - 1)
    end

    it 'should not delete a checkin if it does not belong to the user' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      request.accept = 'text/javascript'
      delete :destroy, params: params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(device.checkins.count).to eq count
    end
  end
end
