require 'rails_helper'

RSpec.describe Users::FriendsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:second_user) { FactoryGirl.create :user }
  let(:device) { FactoryGirl.create :device, user_id: second_user.id }
  let(:checkin) { FactoryGirl.create :checkin, device: device }
  let(:approval) do
    device
    Approval.link(user, second_user, 'User')
    Approval.accept(second_user, user, 'User')
  end
  let(:params) { { id: second_user.id, user_id: user.id, checkin_id: checkin.id, device_id: device.id } }

  describe 'GET #show' do
    it 'should assign @friend and friends devices if friends' do
      approval
      get :show, params: params
      expect(assigns(:friend)).to eq(second_user)
      expect(assigns(:devices)).to eq(second_user.devices)
    end

    it 'should say that you are not friends with user' do
      get :show, params: params
      expect(flash[:notice]).to match 'not friends'
    end
  end

  describe 'GET #show_device' do
    it 'should render the show device page' do
      approval
      get :show_device, params: params
      expect(response.code).to eq '200'
    end
  end
end
