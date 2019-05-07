require "rails_helper"

RSpec.describe Api::V1::Users::RequestsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:user) do
    us = create :user
    Approval.link(us, developer, "Developer")
    Approval.accept(us, developer, "Developer")
    Approval.update_all(status: "complete")
    us
  end
  let(:params) { { user_id: user.id } }

  before { api_request_headers(developer, user) }

  it "gets a list of requests" do
    21.times { get :index, params: params }
    expect(res_hash.length).to eq 21
  end

  it "gets a list of requests made by the developer making the request" do
    get :index, params: params
    expect(res_hash.first["developer_id"]).to eq developer.id
  end

  it "gets the second to last request related to this user" do
    21.times { get :index, params: params }
    get :last, params: params
    expect(res_hash.first["action"]).to eq "index"
  end

  it "gets the second to last request related to this user made by the developer making the request" do
    21.times { get :index, params: params }
    get :last, params: params
    expect(res_hash.first["developer_id"]).to eq developer.id
  end
end
