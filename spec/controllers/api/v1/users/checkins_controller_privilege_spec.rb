require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
  include ControllerMacros, CityMacros, CheckinsSpecHelpers

  let(:developer) { FactoryGirl.create :developer }
  let(:user) { FactoryGirl.create :user }
  let(:device) { FactoryGirl.create :device, user_id: user.id, delayed: 10 }
  let(:second_device) { FactoryGirl.create :device, user_id: user.id, delayed: 10 }
  let(:checkin) { FactoryGirl.create :checkin, device_id: device.id }
  let(:historic_checkin) { FactoryGirl.create :checkin, device_id: device.id, created_at: Time.now - 1.day }
  let(:second_checkin) { FactoryGirl.create :checkin, device_id: second_device.id, created_at: Time.now - 1.minute }
  let(:second_historic) { FactoryGirl.create :checkin, device_id: second_device.id, created_at: Time.now - 1.hour }
  let(:params) { { user_id: user.id } }

  before do
    request.headers['X-Api-Key'] = developer.api_key
    device
    second_device
    Approval.link(user, developer, 'Developer')
    Approval.accept(user, developer, 'Developer')
    historic_checkin # oldest (before delay)
    second_historic # older (before delay)
    second_checkin # old
    checkin # most recent
  end

  context 'with 3 checkins: 2 old, 1 new, on 2 devices' do
    describe 'GET #last/#index' do
      context 'with privilege set to disallowed and bypass_delay set to false' do
        it 'should return 0 checkins' do
          %w(last index).each { |method| call_checkin_action(method, 'disallowed', false, 0, nil) }
        end
      end

      context 'with privilege set to disallowed and bypass_delay set to true' do
        it 'should return 0 checkins' do
          %w(last index).each { |method| call_checkin_action(method, 'disallowed', true, 0, nil) }
        end
      end

      context 'with privilege set to last_only and bypass_delay set to true' do
        it 'should return just the most recent checkins' do
          call_checkin_action('last', 'last_only', true, 1, checkin)
          call_checkin_action('index', 'last_only', true, 2, checkin)
        end
      end

      context 'with privilege set to last_only and bypass_delay set to false' do
        it 'should return just the most recent historic checkins' do
          call_checkin_action('index', 'last_only', false, 2, second_historic)
          call_checkin_action('last', 'last_only', false, 1, second_historic)
        end
      end

      context 'with privilege set to complete and bypass_delay set to true' do
        it 'should return 1 new checkin for last and all checkins for index' do
          call_checkin_action('index', 'complete', true, 4, checkin)
          call_checkin_action('last', 'complete', true, 1, checkin)
        end
      end

      context 'with bypass_delay set to false and privilege set to complete' do
        it 'should return the historic checkin(s), most recent first' do
          call_checkin_action('last', 'complete', false, 1, second_historic)
          call_checkin_action('index', 'complete', false, 2, second_historic)
        end
      end
    end
  end

  context 'with 4 checkins: 2 old, 2 new and a device' do
    before { params[:device_id] = device.id }

    describe 'GET #last/#index' do
      context 'with privilege set to last_only and bypass_delay set to false' do
        it 'should return 1 old checkin' do
          %w(last index).each { |method| call_checkin_action(method, 'last_only', false, 1, historic_checkin) }
          params[:device_id] = second_device.id
          %w(last index).each { |method| call_checkin_action(method, 'last_only', false, 1, second_historic) }
        end
      end

      context 'with privilege set to complete and bypass_delay set to true' do
        it 'should return 1 new checkin for last and 2 checkins for index' do
          call_checkin_action('last', 'complete', true, 1, checkin)
          call_checkin_action('index', 'complete', true, 2, checkin)
          params[:device_id] = second_device.id
          call_checkin_action('last', 'complete', true, 1, second_checkin)
          call_checkin_action('index', 'complete', true, 2, second_checkin)
        end
      end

      context 'with bypass_delay set to false and privilege set to complete' do
        it 'should return the historic checkin' do
          %w(index last).each { |action| call_checkin_action(action, 'complete', false, 1, historic_checkin) }
          params[:device_id] = second_device.id
          %w(index last).each { |action| call_checkin_action(action, 'complete', false, 1, second_historic) }
        end
      end
    end
  end
end
