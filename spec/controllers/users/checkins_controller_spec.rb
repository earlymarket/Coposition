require 'rails_helper'

RSpec.describe Users::CheckinsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:device) { FactoryGirl.create :device, user_id: user.id }
  let(:new_user) { create_user }
  let(:checkin) { FactoryGirl.create :checkin, device: device }
  let(:params) { { user_id: user.username, device_id: device.id, id: checkin.id } }
  let(:update_lat_params) { params.merge(checkin: { lat: 10 }) }

  describe 'GET #new' do
    it 'assigns a device with a matching :device_id to @device and a new checkin to @checkin' do
      get :new, params: params
      expect(assigns(:checkin)).to be_a_new(Checkin)
      expect(assigns(:device)).to eq(Device.find(device.id))
    end
  end

  describe 'POST #create' do
    it 'assigns a device, creates a new checkin and assigns it to @checkin' do
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
      expect(assigns(:checkin).edited).to be false
    end
  end

  describe 'POST #import' do
    it 'returns an alert if no file provided' do
      post :import, params: { user_id: user.id, device_id: device.id }
      expect(response).to redirect_to(user_devices_path(user.url_id))
      expect(flash[:alert]).to match('must choose a CSV file')
    end
  end

  describe 'GET #show' do
    it 'assigns :checkin to @checkin if user owns device which owns checkin' do
      request.accept = 'text/javascript'
      get :show, params: params
      expect(assigns(:checkin)).to eq(Checkin.find(checkin.id))
    end

    it 'does not assign :checkin if user does not own device which owns checkin' do
      user
      request.accept = 'text/javascript'
      get :show, params: params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(assigns(:checkin)).to eq nil
    end
  end

  describe 'PUT #update' do
    it 'switches fogging if no extra params' do
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
      expect(checkin.edited).to be false
    end

    it 'updates lat/lng if valid lat/lng provided' do
      request.accept = 'text/javascript'
      put :update, params: update_lat_params
      checkin.reload
      expect(checkin.lat).to eq 10
      expect(checkin.edited).to be true
    end
  end

  describe 'DELETE #destroy_all' do
    it 'deletes all checkins belonging to a device if user owns device' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      delete :destroy_all, params: {
        user_id: user.username,
        device_id: device.id
      }
      expect(device.checkins.count).to eq 0
    end

    it 'does not delete all checkins if user does not own device' do
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
    it 'deletes a checkin by id' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      request.accept = 'text/javascript'
      delete :destroy, params: params
      expect(device.checkins.count).to eq(count - 1)
    end

    it 'does not delete a checkin if it does not belong to the user' do
      count = checkin.device.checkins.count
      expect(count).to be > 0
      request.accept = 'text/javascript'
      delete :destroy, params: params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(device.checkins.count).to eq count
    end
  end
end
