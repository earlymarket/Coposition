require 'rails_helper'

RSpec.describe Users::FriendsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:second_user) { FactoryGirl.create :user }
  let(:device) { FactoryGirl.create :device, user_id: second_user.id, delayed: 10 }
  let(:checkin) { FactoryGirl.create :checkin, device: device }
  let(:historic_checkin) { FactoryGirl.create :checkin, device: device, created_at: Time.now - 1.day }
  let(:approval) do
    device
    Approval.link(user, second_user, 'User')
    Approval.accept(second_user, user, 'User')
  end
  let(:params) { { id: second_user.id, user_id: user.id, device_id: device.id } }

  before do
    approval
    device
    checkin
    historic_checkin
  end

  describe 'GET #show' do
    it 'should assign @friend and friends devices if friends' do
      get :show, params: params
      expect(assigns(:friend)).to eq(second_user)
      expect(assigns(:devices)).to eq(second_user.devices)
    end

    context 'permission disallowed' do
      it 'should render no checkins' do
        device.permission_for(user).update! privilege: 'disallowed'
        get :show, params: params
        expect((assigns :presenter).index_gon[:checkins].size).to eq 0
      end
    end

    context 'permission complete, bypass delay false, bypass fogging false' do
      it 'should render one historic fogged checkin' do
        device.permission_for(user).update! privilege: 'complete', bypass_delay: false, bypass_fogging: false
        get :show, params: params
        checkins = (assigns :presenter).index_gon[:checkins]
        expect(checkins.size).to eq 1
        expect(checkins[0]['lat'].round(6)).to eq historic_checkin.fogged_lat.round(6)
        expect(checkins[0]['id']).to eq historic_checkin.id
      end
    end

    context 'permission complete, bypass delay true, bypass fogging true' do
      it 'should render two unfogged checkins' do
        device.permission_for(user).update! privilege: 'complete', bypass_delay: true, bypass_fogging: true
        get :show, params: params
        expect((assigns :presenter).index_gon[:checkins][0]['lat'].round(6)).to eq checkin.lat.round(6)
        expect((assigns :presenter).index_gon[:checkins].size).to eq 1
      end
    end

    it 'should say that you are not friends with user' do
      Approval.all.destroy_all
      get :show, params: params
      expect(flash[:notice]).to match 'not friends'
    end
  end

  describe 'GET #show_device' do
    it 'should render the show device page' do
      get :show_device, params: params
      expect(response.code).to eq '200'
    end

    context 'permission disallowed' do
      it 'should render no checkins' do
        device.permission_for(user).update! privilege: 'disallowed'
        get :show_device, params: params
        expect((assigns :presenter).show_device_gon[:checkins].size).to eq 0
      end
    end

    context 'permission last_only, bypass delay false' do
      it 'should render one historic_checkin' do
        device.permission_for(user).update! privilege: 'last_only', bypass_delay: false
        get :show_device, params: params
        expect((assigns :presenter).show_device_gon[:checkins].size).to eq 1
        expect((assigns :presenter).show_device_gon[:checkins][0]['id']).to eq historic_checkin.id
      end
    end

    context 'permission last_only, bypass delay true' do
      it 'should render one recent checkin' do
        device.permission_for(user).update! privilege: 'last_only', bypass_delay: true
        get :show_device, params: params
        expect((assigns :presenter).show_device_gon[:checkins][0]['id']).to eq checkin.id
        expect((assigns :presenter).show_device_gon[:checkins].size).to eq 1
      end
    end

    context 'permission complete, bypass delay false, bypass fogging false' do
      it 'should render one historic fogged checkin' do
        device.permission_for(user).update! privilege: 'complete', bypass_delay: false, bypass_fogging: false
        get :show_device, params: params
        checkins = (assigns :presenter).show_device_gon[:checkins]
        expect(checkins[0]['id']).to eq historic_checkin.id
        expect(checkins[0]['lat'].round(6)).to eq historic_checkin.fogged_lat.round(6)
        expect(checkins.size).to eq 1
      end
    end

    context 'permission complete, bypass delay true, bypass fogging true' do
      it 'should render two unfogged checkins' do
        device.permission_for(user).update! privilege: 'complete', bypass_delay: true, bypass_fogging: true
        get :show_device, params: params
        expect((assigns :presenter).show_device_gon[:checkins].size).to eq 2
        expect((assigns :presenter).show_device_gon[:checkins][0]['lat'].round(6)).to eq checkin.lat.round(6)
      end
    end
  end
end
