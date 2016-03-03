require 'rails_helper'

RSpec.describe Users::FriendsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:second_user) { FactoryGirl::create :user }
  let(:device) { FactoryGirl::create :device, user_id: second_user.id }
  let(:checkin) do
    check = FactoryGirl::create(:checkin)
    device.checkins << check
    check
  end
  let(:approval) do
    device
    Approval.link(user, second_user, 'User')
    Approval.accept(second_user, user, 'User')
  end
  let(:params) {{ id: second_user.id, user_id: user.id, checkin_id: checkin.id, device_id: device.id }}

  describe "GET #show" do
    it 'should assign @friend and friends devices if friends' do
      approval
      get :show, params
      expect(assigns :friend).to eq(second_user)
      expect(assigns :devices).to eq(second_user.devices)
    end

    it 'should say that you are not friends with user' do
      get :show, params
      expect(flash[:notice]).to match "not friends"
    end
  end

  describe "GET #show_device" do
    it 'should assign friend, device and checkins' do
      approval
      get :show_device, params
      expect(assigns :friend).to eq(second_user)
      expect(assigns :device).to eq(device)
      expect(assigns :checkins).to eq(device.checkins)
    end
  end

  describe "GET #show_checkin" do
    it 'should assign checkin and fogged checkin' do
      approval
      get :show_checkin, params
      expect(assigns :checkin).to eq(device.checkins.first)
      expect(assigns :fogged).to eq(device.checkins.first.resolve_address(user, 'address'))
    end

  end

end
