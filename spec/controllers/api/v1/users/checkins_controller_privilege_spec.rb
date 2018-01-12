require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros, CheckinsSpecHelpers

  let(:developer) { create :developer }
  let(:user) { create :user }
  let!(:device) { create :device, user_id: user.id, delayed: 10 }
  let!(:second_device) { create :device, user_id: user.id, delayed: 10, name: "Second device" }
  let!(:checkin) { create :checkin, device_id: device.id }
  let!(:historic_checkin) { create :checkin, device_id: device.id, created_at: Time.now - 1.day }
  let!(:second_checkin) { create :checkin, device_id: second_device.id, created_at: Time.now - 1.minute }
  let!(:second_historic) { create :checkin, device_id: second_device.id, created_at: Time.now - 1.hour }
  let(:params) { { user_id: user.id } }

  before do
    api_request_headers(developer, user)
    Approval.link(user, developer, 'Developer')
    Approval.accept(user, developer, 'Developer')
    Approval.last.update(status: "complete")
  end

  context 'with 3 checkins: 2 old, 1 new, on 2 devices' do
    describe 'GET #last/#index' do
      context 'with device cloaked' do
        it 'should return 0 checkins' do
          # call_checkin_action(method, no. of checkins returned, first checkin)
          Device.all.each { |device| device.update! cloaked: true }
          %w(last index).each { |method| call_checkin_action(method, 0, nil) }
        end
      end

      context 'with privilege set to disallowed and bypass_delay set to false' do
        it 'should return 0 checkins' do
          Device.all.each { |device| update_permissions(device, 'disallowed', false) }
          %w(last index).each { |method| call_checkin_action(method, 0, nil) }
        end
      end

      context 'with privilege set to disallowed and bypass_delay set to true' do
        it 'should return 0 checkins' do
          Device.all.each { |device| update_permissions(device, 'disallowed', true) }
          %w(last index).each { |method| call_checkin_action(method, 0, nil) }
        end
      end

      context 'with privilege set to last_only and bypass_delay set to false' do
        it 'should return just the most recent historic checkins' do
          Device.all.each { |device| update_permissions(device, 'last_only', false) }
          call_checkin_action('index', 2, second_historic)
          call_checkin_action('last', 1, second_historic)
        end
      end

      context 'with privilege set to last_only and bypass_delay set to true' do
        it 'should return just the most recent checkins' do
          Device.all.each { |device| update_permissions(device, 'last_only', true) }
          call_checkin_action('last', 1, checkin)
          call_checkin_action('index', 2, checkin)
        end
      end

      context 'with privilege set to complete and bypass_delay set to false' do
        it 'should return the historic checkin(s), most recent first' do
          Device.all.each { |device| update_permissions(device, 'complete', false) }
          call_checkin_action('last', 1, second_historic)
          call_checkin_action('index', 2, second_historic)
        end
      end

      context 'with privilege set to complete and bypass_delay set to true' do
        it 'should return 1 new checkin for last and all checkins for index' do
          Device.all.each { |device| update_permissions(device, 'complete', true) }
          call_checkin_action('index', 4, checkin)
          call_checkin_action('last', 1, checkin)
        end
      end

      context 'with privilege set to disallowed and last_only and bypass_delay set to false' do
        it 'should return 1 historic checkin from second device' do
          update_permissions(device, 'disallowed', false)
          update_permissions(second_device, 'last_only', false)
          call_checkin_action('index', 1, second_historic)
          call_checkin_action('last', 1, second_historic)
        end
      end

      context 'with privilege set to disallowed and last_only and bypass_delay set to true' do
        it 'should return 1 checkin from second device' do
          update_permissions(device, 'disallowed', true)
          update_permissions(second_device, 'last_only', true)
          call_checkin_action('index', 1, second_checkin)
          call_checkin_action('last', 1, second_checkin)
        end
      end

      context 'with privilege set to last_only and complete and bypass_delay set to false' do
        it 'should return 1 historic checkin from second device for last and both historic for index' do
          update_permissions(device, 'last_only', false)
          update_permissions(second_device, 'complete', false)
          call_checkin_action('index', 2, second_historic)
          call_checkin_action('last', 1, second_historic)
        end
      end

      context 'with privilege set to last_only and complete and bypass_delay set to true' do
        it 'should return 1 new checkin for last and 3 checkins for index' do
          update_permissions(device, 'last_only', true)
          update_permissions(second_device, 'complete', true)
          call_checkin_action('index', 3, checkin)
          call_checkin_action('last', 1, checkin)
        end
      end

      context 'with privilege set to disallowed and complete and bypass_delay set to false' do
        it 'should return 1 historic checkin from second device' do
          update_permissions(device, 'disallowed', false)
          update_permissions(second_device, 'complete', false)
          call_checkin_action('index', 1, second_historic)
          call_checkin_action('last', 1, second_historic)
        end
      end

      context 'with privilege set to disallowed and complete and bypass_delay set to true' do
        it 'should return 1 checkin for last and all checkins for index from second device' do
          update_permissions(device, 'disallowed', true)
          update_permissions(second_device, 'complete', true)
          call_checkin_action('index', 2, second_checkin)
          call_checkin_action('last', 1, second_checkin)
        end
      end
    end
  end

  context 'with 4 checkins: 2 old, 2 new and a device' do
    before { params[:device_id] = device.id }

    describe 'GET #last/#index' do
      context 'with privilege set to last_only and bypass_delay set to false' do
        it 'should return 1 old checkin' do
          Device.all.each { |device| update_permissions(device, 'last_only', false) }
          %w(last index).each { |method| call_checkin_action(method, 1, historic_checkin) }
          params[:device_id] = second_device.id
          %w(last index).each { |method| call_checkin_action(method, 1, second_historic) }
        end
      end

      context 'with privilege set to complete and bypass_delay set to true' do
        it 'should return 1 new checkin for last and 2 checkins for index' do
          Device.all.each { |device| update_permissions(device, 'complete', true) }
          call_checkin_action('last', 1, checkin)
          call_checkin_action('index', 2, checkin)
          params[:device_id] = second_device.id
          call_checkin_action('last', 1, second_checkin)
          call_checkin_action('index', 2, second_checkin)
        end
      end

      context 'with bypass_delay set to false and privilege set to complete' do
        it 'should return the historic checkin' do
          Device.all.each { |device| update_permissions(device, 'complete', false) }
          %w(index last).each { |action| call_checkin_action(action, 1, historic_checkin) }
          params[:device_id] = second_device.id
          %w(index last).each { |action| call_checkin_action(action, 1, second_historic) }
        end
      end
    end
  end
end
