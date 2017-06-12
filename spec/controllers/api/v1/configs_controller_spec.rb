require "rails_helper"

RSpec.describe Api::V1::ConfigsController, type: :controller do
  include ControllerMacros

  let(:developer) do
    developer = create :developer
    developer.configs.create(device: device)
    developer
  end
  let(:device) { create :device }
  let(:params) { { id: device.id } }
  let(:custom_params) { { type: "tracker", freq: "1000" } }
  let(:update_params) { params.merge(config: { custom: custom_params }) }

  before do
    request.headers["X-Api-Key"] = developer.api_key
  end

  describe "#index" do
    it "returns a list of configs which the developer controls" do
      get :index
      expect(res_hash.first["developer_id"]).to eq developer.id
    end
  end

  describe "#show" do
    before do
      request.headers["X-Api-Key"] = (create :developer).api_key
    end

    it "returns nothing if developer doesn't control device" do
      get :show, params: params
      expect(res_hash[:error]).to match "Couldn't find Config"
    end

    it "returns a config for the specified device" do
      request.headers["X-Api-Key"] = developer.api_key
      get :show, params: params
      expect(res_hash[:device_id]).to eq device.id
    end

    it "returns a config if request from copo+app" do
      request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
      get :show, params: params
      expect(res_hash[:device_id]).to eq device.id
    end
  end

  describe "#update" do
    it "updates a config for the specified device" do
      put :update, params: update_params
      expect(res_hash[:custom]).to eq custom_params.as_json
    end

    it "returns a message if config does not exist" do
      put :update, params: update_params.merge(id: 0)
      expect(res_hash[:error]).to match "Couldn't find Config"
    end
  end
end
