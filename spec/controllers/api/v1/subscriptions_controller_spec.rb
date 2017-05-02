require 'rails_helper'

RSpec.describe Api::V1::SubscriptionsController, type: :controller do
  include ControllerMacros

  let(:user) { create :user }
  let(:subscription) { create :subscription, subscriber: user }
  let(:params) { { target_url: "http://#{Faker::Internet.domain_name}/", event: 'new_checkin' } }
  let(:destroy_params) { params.merge(id: subscription.id) }

  before do
    request.headers['X-Authentication-Key'] = user.webhook_key
  end

  describe '#create' do
    it 'should create a new user subscription' do
      count = user.subscriptions.count
      post :create, params: params
      expect(user.subscriptions.count).to eq count + 1
      expect(response.status).to be 201
      expect(res_hash[:id]).to be user.subscriptions.last.id
    end
  end

  describe '#destroy' do
    it 'should destroy a subscription' do
      subscription
      count = user.subscriptions.count
      delete :destroy, params: destroy_params
      expect(res_hash[:id]).to be subscription.id
      expect(response.status).to be 200
      expect(user.subscriptions.count).to eq count - 1
    end
  end
end
