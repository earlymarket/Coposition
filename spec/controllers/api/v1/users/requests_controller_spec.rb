require "rails_helper"

RSpec.describe Api::V1::Users::RequestsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:second_dev) { create_developer }
  let(:user) do
    us = create :user
    Approval.link(us, developer, "Developer")
    Approval.link(us, second_dev, "Developer")
    Approval.accept(us, developer, "Developer")
    Approval.accept(us, second_dev, "Developer")
    Approval.update_all(status: "complete")
    us
  end
  let(:user_params) { { user_id: user.id } }
  let(:dev_params) { { user_id: user.id, developer_id: developer.id } }

  before { api_request_headers(developer, user) }

  it "gets a list of requests" do
    21.times { get :index, params: user_params }
    expect(res_hash.length).to eq 21
  end

  it "gets a list of (developer) requests specific to a developer" do
    get :index, params: dev_params
    expect(res_hash.first["developer_id"]).to eq(developer.id)
    get :index, params: dev_params.merge(developer_id: 999)
    expect(res_hash[:requests]).to eq([])
  end

  it "gets the second to last request related to this user" do
    21.times { get :index, params: user_params }
    get :last, params: user_params
    expect(res_hash.first["action"]).to eq "index"
    expect(res_hash.length).to eq 1
  end

  it "gets the second to last request related to this user made by this developer" do
    21.times { get :index, params: user_params }
    get :last, params: dev_params
    expect(res_hash.first["action"]).to eq "index"
  end

  it "gets the last request related to this user made by another developer" do
    api_request_headers(second_dev, user)
    21.times { get :index, params: user_params }
    api_request_headers(developer, user)
    get :last, params: dev_params.merge(developer_id: second_dev.id)
    expect(res_hash.first["action"]).to eq "index"
  end
end
