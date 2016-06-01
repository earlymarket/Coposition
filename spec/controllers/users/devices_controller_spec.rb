require 'rails_helper'

RSpec.describe Users::DevicesController, type: :controller do
  include ControllerMacros

  let(:empty_device) { FactoryGirl.create :device }
  let(:checkin) { FactoryGirl.create(:checkin, created_at: Date.yesterday) }
  let(:device) do
    dev = FactoryGirl.create :device
    dev.checkins << [checkin, FactoryGirl.create(:checkin)]
    dev
  end
  let(:developer) { FactoryGirl.create :developer }
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
  let(:approval) { create_approval(user, new_user) }
  let(:user_param) { { user_id: user.username } }
  let(:params) { user_param.merge(id: device.id) }
  let(:date_params) { params.merge(from: Date.yesterday, to: Date.yesterday) }

  it 'should have a current_user' do
    user
    expect(subject.current_user).to_not be nil
  end

  describe 'GET #index' do
    it 'should assign current_user.devices to @devices' do
      get :index, user_param
      expect(assigns(:devices)).to eq(user.devices)
    end
  end

  describe 'GET #show' do
    it 'should assign :id.device to @device if user owns device' do
      get :show, params
      expect(assigns(:device)).to eq(Device.find(device.id))
    end

    it 'should not assign to @device if user does not own device' do
      get :show, params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(assigns(:device)).to eq(nil)
    end

    it 'should redirect to root path and render error message if device doesnt exist' do
      get :show, params.merge(id: 1000)
      expect(flash[:alert]).to eq "Couldn't find Device with 'id'=1000"
      expect(response).to redirect_to(root_path)
    end

    it 'should create a CSV file if .csv appended to url' do
      get :show, params.merge(format: :csv)
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.body).to include(checkin.attributes.keys.join(','))
      expect(response.body).to include(checkin.attributes.values.join(','))
    end
  end

  describe 'GET #new' do
    it 'should assign :uuid to @device.uuid if exists' do
      get :new, user_param
      expect(assigns(:device).uuid).to eq(nil)
      get :new, user_param.merge(uuid: '123412341234')
      expect(assigns(:device).uuid).to eq('123412341234')
    end
  end

  describe 'GET #shared' do
    it 'should deny access if device not published' do
      get :shared, params
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to match('not shared')
    end

    it 'should render page if published' do
      device.published = true
      get :shared, params
      expect(response).to render_template('shared')
    end
  end

  describe 'POST #create' do
    it 'should create a new device' do
      count = user.devices.count
      post :create, user_param.merge(device: { name: 'New Device' })
      expect(response.code).to eq '302'
      expect(user.devices.count).to be count + 1
      expect(user.devices.all.last.name).to eq 'New Device'
    end

    it 'should create a device with a given UUID' do
      count = user.devices.count
      post :create, user_param.merge(device: { name: 'New Device', uuid: empty_device.uuid })
      expect(response.code).to eq '302'
      expect(user.devices.count).to be count + 1
      expect(user.devices.all.last).to eq empty_device
    end

    it 'should create a new device and a checkin if location provided' do
      devices_count = user.devices.count
      checkins_count = Checkin.count
      post :create, user_param.merge(
        location: '51.588330,-0.513069',
        device: { name: 'New Device' },
        create_checkin: true
      )
      expect(user.devices.count).to be devices_count + 1
      expect(Checkin.count).to be checkins_count + 1
      expect(Checkin.last.lat).to eq 51.588330
    end

    it 'should fail to to create a device with an invalid UUID' do
      count = user.devices.count
      post :create, user_param.merge(device: { uuid: 123 })
      expect(response).to redirect_to(new_user_device_path)
      expect(user.devices.count).to be count
    end

    it 'should fail to to create a device when the device is assigned to a user' do
      count = user.devices.count
      taken_uuid = user.devices.last.uuid
      post :create, user_param.merge(device: { uuid: taken_uuid })
      expect(response).to redirect_to(new_user_device_path)
      expect(user.devices.count).to be count
    end

    it 'should fail to to create a device with a duplicate username' do
      taken_name = user.devices.last.name
      count = user.devices.count
      post :create, user_param.merge(device: { name: taken_name })
      expect(user.devices.count).to be count
      expect(response).to redirect_to(new_user_device_path)
    end
  end

  describe 'PUT #update' do
    it 'should switch fogging status to true by default' do
      expect(device.fogged?).to be false
      request.accept = 'text/javascript'
      put :update, params

      device.reload
      expect(device.fogged?).to be true

      request.accept = 'text/javascript'
      put :update, params

      device.reload
      expect(device.fogged?).to be false
    end

    it 'should switch published status' do
      expect(device.published?).to be false
      request.accept = 'text/javascript'
      put :update, params.merge(published: true)

      device.reload
      expect(device.published?).to be true
    end

    it 'should set a delay' do
      request.accept = 'text/javascript'
      put :update, params.merge(delayed: 5)
      expect(flash[:notice]).to include 'minutes'
      put :update, params.merge(delayed: 100)
      expect(flash[:notice]).to include 'hour'
      put :update, params.merge(delayed: 1440)
      expect(flash[:notice]).to include 'day'
      device.reload
      expect(device.delayed).to be 1440
    end

    it 'should set a delay of 0 as nil' do
      request.accept = 'text/javascript'
      put :update, params.merge(delayed: 0)

      device.reload
      expect(device.delayed).to be nil
    end
  end

  describe 'DELETE #destroy' do
    it 'should delete' do
      user
      count = Device.count
      delete :destroy, params

      expect(Device.count).to be count - 1
    end

    it 'should not delete if user does not own device' do
      user
      count = Device.count
      delete :destroy, params.merge(user_id: new_user.username)
      expect(response).to redirect_to(root_path)
      expect(Device.count).to be count
    end
  end
end
