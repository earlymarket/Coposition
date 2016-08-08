require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include ControllerMacros

  let(:dev) { FactoryGirl.create :developer }
  let(:user) { FactoryGirl.create :user }

  describe '#show' do
    context 'without an API key' do
      it 'should render status 401 with message' do
        get :show, id: user.id, format: :json
        expect(response.status).to eq 401
        expect(res_hash[:error]).to eq 'No valid API Key'
      end
    end

    context 'with a correct API key' do
      before do
        request.headers['X-Api-Key'] = dev.api_key
      end

      it 'should reject an unapproved user' do
        get :show, id: user.id, format: :json
        expect(response.status).to eq 401
      end

      it 'should assign User.id(:id) to @user if the developer is approved' do
        Approval.link(user, dev, 'Developer')
        Approval.accept(user, dev, 'Developer')
        get :show, id: user.id, format: :json
        expect(assigns(:user)).to eq(User.find(user.id))
      end

      it 'should return 404 and an error message if user does not exist' do
        get :show, id: 1000, format: :json
        expect(response.status).to eq 404
        expect(res_hash[:error]).to eq "Couldn't find User with 'id'=1000"
      end
    end
  end

  describe '#index' do
    before do
      request.headers['X-Api-Key'] = dev.api_key
      Approval.link(user, dev, 'Developer')
      Approval.accept(user, dev, 'Developer')
    end

    it 'should return a list of a developers approved users' do
      get :index, format: :json
      expect(assigns(:users)).to eq([User.find(user.id)])
    end
  end

  describe '#auth' do
    context 'with a valid webhook key in header' do
      it 'should return status 204 and json message "success"' do
        request.headers['X-Authentication-Key'] = user.webhook_key
        get :auth
        expect(response.status).to eq 204
        expect(res_hash[:message]).to eq 'Success'
      end
    end
    context 'without a valid webhook key in header' do
      it 'should return status 400 and json message "Invalid webhook key supplied"' do
        get :auth
        expect(response.status).to eq 400
        expect(res_hash[:error]).to eq 'Invalid webhook key supplied'
      end
    end
  end
end
