require 'rails_helper'

RSpec.describe Api::V1::Users::RequestsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:second_dev) { create_developer }
  let(:user) do
    us = FactoryGirl.create :user
    Approval.link(us, developer, 'Developer')
    Approval.link(us, second_dev, 'Developer')
    Approval.accept(us, developer, 'Developer')
    Approval.accept(us, second_dev, 'Developer')
    us
  end
  let(:user_params) { { params: { user_id: user.id } } }
  let(:dev_params) { { params: { user_id: user.id, developer_id: developer.id } } }

  before do
    request.headers['X-Api-Key'] = developer.api_key
  end

  it 'should get a list of requests' do
    21.times { get :index, user_params }
    expect(res_hash.length).to eq 21
  end

  it 'should get a list of (developer) requests specific to a developer' do
    get :index, dev_params
    expect(res_hash.first['developer_id']).to eq(developer.id)
    dev_params[:params][:developer_id] = 999999
    get :index, dev_params
    expect(response.body).to eq('[]')
  end

  it 'should get the second to last request related to this user' do
    21.times { get :index, user_params }
    get :last, user_params
    expect(res_hash.first['action']).to eq 'index'
    expect(res_hash.length).to eq 1
  end

  it 'should get the second to last request related to this user made by this developer' do
    21.times { get :index, user_params }
    get :last, dev_params
    expect(res_hash.first['action']).to eq 'index'
  end

  it 'should get the last request related to this user made by another developer' do
    request.headers['X-Api-Key'] = second_dev.api_key
    21.times { get :index, user_params }
    request.headers['X-Api-Key'] = developer.api_key
    dev_params[:params][:developer_id] = second_dev.id
    get :last, dev_params
    expect(res_hash.first['action']).to eq 'index'
  end
end
