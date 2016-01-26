require 'rails_helper'

RSpec.describe Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:empty_device) { FactoryGirl::create :device }
  let(:device) { FactoryGirl::create :device }
  let(:developer) { FactoryGirl::create :developer }
  let(:user) do
    user = create_user
    user.devices << device
    user.devices.each do |device|
      device.developers << developer
      device.save
    end
    user
  end
  let(:new_user) { create_user }
  let(:priv) { user.devices.last.privilege_for(developer) }
  let(:approval) { create_approval(user, new_user) }

  it 'should have a current_user' do
    user
    expect(subject.current_user).to_not be nil
  end

  describe 'GET #index' do
    it 'should assign current_user.devices to @devices' do
      get :index, user_id: user.username
      expect(assigns :devices).to eq(user.devices)
    end
  end

  describe 'GET #show' do
    it 'should assign :id.device to @device if user owns device' do
      get :show, {
        user_id: user.username,
        id: device.id
      }
      expect(assigns :device).to eq(Device.find(device.id))
    end

    it 'should not assign to @device if user does not own device' do
      get :show, {
        user_id: new_user.username,
        id: device.id
      }
      expect(response).to redirect_to(root_path)
      expect(assigns :device).to eq(nil)
    end

    it 'should assign @fogmessage' do
      device.switch_fog
      get :show, {
        user_id: user.username,
        id: device.id
      }
      expect(assigns :fogmessage).to eq("Currently fogged")
    end
  end

  describe 'GET #new' do
    it 'should assign :uuid to @device.uuid if exists' do
      get :new, {
        user_id: user.username
      }
      expect(assigns(:device).uuid).to eq(nil)
      get :new, {
        user_id: user.username,
        uuid: '123412341234'
      }
      expect(assigns(:device).uuid).to eq('123412341234')
    end

    it 'should set @adding_current_device to true if :curr_device exists' do
      get :new, {
        user_id: user.username
      }
      expect(assigns :adding_current_device).to eq(nil)
      get :new, {
        user_id: user.username,
        curr_device: true
      }
      expect(assigns :adding_current_device).to eq(true)
    end

    it 'should assign :redirect to @redirect_target if exists' do
      get :new, {
        user_id: user.username,
      }
      expect(assigns :redirect_target).to eq(nil)
      get :new, {
        user_id: user.username,
        redirect: 'http://www.coposition.com/'
      }
      expect(assigns :redirect_target).to eq('http://www.coposition.com/')
    end
  end

  describe 'GET #add_current' do
    it 'should create a a new Device with a UUID' do
      user
      count = Device.count
      get :add_current, {
        user_id: user.username
      }
      expect(Device.count).to eq(count+1)
      expect(Device.last.uuid == nil).to be false
    end
  end

  describe 'DELETE #checkin' do
    it 'should delete a checkin by :checkin_id' do
      device.checkins << FactoryGirl::create(:checkin)
      count = device.checkins.count
      request.accept = 'text/javascript'
      delete :checkin, {
        user_id: user.username,
        id: device.id,
        checkin_id: device.checkins.last.id
      }
      expect(device.checkins.count).to eq(count-1)
    end

    it 'should not delete a checkin if user does not own device' do
      device.checkins << FactoryGirl::create(:checkin)
      count = device.checkins.count
      request.accept = 'text/javascript'
      delete :checkin, {
        user_id: new_user.username,
        id: device.id,
        checkin_id: device.checkins.last.id
      }
      expect(response).to redirect_to(root_path)
      expect(device.checkins.count).to eq(count)
    end
  end

  describe 'posting' do
    context 'to #create' do

      it 'should create a new device' do
        count = user.devices.count
        post :create, {
          user_id: user.username,
          device: { name: 'New Device' }
        }
        expect(response.code).to eq '302'
        expect(user.devices.count).to be count+1
        expect(user.devices.all.last.name).to eq 'New Device'
      end

      it 'should create a device with a given UUID' do
        count = user.devices.count
        post :create, {
          user_id: user.username,
          device: { uuid: empty_device.uuid }
        }
        expect(response.code).to eq '302'
        expect(user.devices.count).to be count+1
        expect(user.devices.all.last).to eq empty_device
      end

      it 'should create a new device and redirect if provided' do
        count = user.devices.count
        post :create, {
          user_id: user.username,
          redirect: 'http://www.coposition.com/',
          device: { name: 'New Device' }
        }
        expect(user.devices.count).to be count+1
        expect(response).to redirect_to('http://www.coposition.com/')
      end

      it 'should create a new device and a checkin if location provided' do
        devices_count = user.devices.count
        checkins_count = Checkin.count
        post :create, {
          user_id: user.username,
          location: '51.588330,-0.513069',
          device: { name: 'New Device' }
        }
        expect(user.devices.count).to be devices_count+1
        expect(Checkin.count).to be checkins_count+1
        expect(Checkin.last.lat).to eq 51.588330
      end

      it 'should fail to to create a device with an invalid UUID' do
        count = user.devices.count
        post :create, {
          user_id: user.username,
          device: { uuid: 123 }
        }
        expect(response).to redirect_to(new_user_device_path)
        expect(user.devices.count).to be count
      end

      it 'should fail to to create a device when the device is assigned to a user' do
        count = new_user.devices.count
        taken_uuid = user.devices.last.uuid
        post :create, {
          user_id: new_user.username,
          device: { uuid: taken_uuid }
        }
        expect(response).to redirect_to(new_user_device_path)
        expect(new_user.devices.count).to be count
      end
    end

    it 'should switch fogging status to true by default' do
      expect(device.fogged?).to be false
      request.accept = 'text/javascript'
      put :fog, {
        user_id: user.username,
        id: device.id
      }

      device.reload
      expect(device.fogged?).to be true
      
      request.accept = 'text/javascript'
      put :fog, {
        user_id: user.username,
        id: device.id
      }

      device.reload
      expect(device.fogged?).to be false
    end

    it 'should set a delay' do
      request.accept = 'text/javascript'
      post :set_delay, {
        id: device.id,
        user_id: user.username,
        mins: 13
      }

      device.reload
      expect(device.delayed).to be 13
    end

    context "switch privilege" do

      it 'should switch privilege for a developer' do
        priv
        request.accept = 'text/javascript'
        post :switch_privilege, {
          id: user.devices.last.id,
          user_id: user.username,
          developer: developer.id
        }
        expect(user.devices.last.privilege_for(developer)).to_not be priv
      end

      it 'should switch privilege for a user' do
        new_user
        approval.approve!
        priv = user.devices.last.privilege_for(new_user)
        request.accept = 'text/javascript'
        post :switch_privilege, {
          id: user.devices.last.id,
          user_id: user.username,
          user: new_user.id
        }
        expect(user.devices.last.privilege_for(new_user)).to_not be priv
      end

      it 'should switch privilege for a developer on all devices' do
        priv
        request.accept = 'text/javascript'
        post :switch_all_privileges, {
          user_id: user.username,
          developer: developer.id
        }
        user.devices.each { |device| expect(device.privilege_for(developer)).to_not be priv }
      end

      it 'should switch privilege for a developer' do
        new_user
        approval.approve!
        priv = user.devices.last.privilege_for(new_user)
        request.accept = 'text/javascript'
        post :switch_all_privileges, {
          user_id: user.username,
          user: new_user.id
        }
        user.devices.each { |device| expect(device.privilege_for(new_user)).to_not be priv }
      end

    end

    it 'should delete' do
      user
      count = Device.count
      delete :destroy, {
        user_id: user.username,
        id: device.id
      }

      expect(Device.count).to be count-1
    end

    it 'should not delete if user does not own device' do
      user
      count = Device.count
      delete :destroy, {
        user_id: new_user.username,
        id: device.id
      }
      expect(response).to redirect_to(root_path)
      expect(Device.count).to be count
    end

  end

  describe 'posting from app', :type => :request do

    it 'should POST to create with a UUID' do
      count = user.devices.count
      headers = {
        "X-Api-Key" => developer.api_key,
        "X-User-Token" => user.authentication_token,
        "X-User-Email" => user.email,
        "X-Secret-App-Key" => Rails.application.secrets.mobile_app_key
      }
      post "/users/#{user.username}/devices", {
        device: { uuid: empty_device.uuid }
      }, headers
      expect(user.devices.count).to be(count+1)
      expect(user.devices.all.last).to eq empty_device
    end

    it 'should fail to to create a device with an invalid UUID' do
      count = user.devices.count
      headers = {
        "X-Api-Key" => developer.api_key,
        "X-User-Token" => user.authentication_token,
        "X-User-Email" => user.email,
        "X-Secret-App-Key" => Rails.application.secrets.mobile_app_key
      }
      post "/users/#{user.username}/devices", {
        device: { uuid: 123 }
      }, headers

      expect(response.code).to eq '400'
      expect(user.devices.count).to be count
    end

  end
end
