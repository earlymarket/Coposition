require 'rails_helper'

RSpec.describe Api::V1::ReleaseNotesController, type: :controller do
  include ControllerMacros

  let(:dev) { create :developer }
  let!(:release_note) { create :release_note }
  let(:params) { { application: "web", version: "v1.0.0" } }

  before do
    request.headers["X-Api-Key"] = dev.api_key
    request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
  end

  describe "#index" do
    it "is a success" do
      get :index, params: params
      expect(response.status).to be 200
    end

    it "returns release notes with application and version matching those provided" do
      get :index, params: params
      expect(res_hash.first["id"]).to be release_note.id
    end
  end
end
