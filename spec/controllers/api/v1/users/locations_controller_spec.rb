require "rails_helper"

RSpec.describe Api::V1::Users::LocationsController, type: :controller do
  include ControllerMacros

  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
  let!(:device) { FactoryGirl.create :device, user: user }
  let(:address) do
    "The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK"
  end
  let(:params) { { user_id: user.id } }

  before do
    api_request_headers(developer, user)

    Approval.create(
      user: user,
      approvable: developer,
      approvable_type: "Developer",
      status: "developer-requested"
    ).complete!
  end

  describe "GET #index when the device has 31 locations" do
    before do
      60.times do
        FactoryGirl.create :location, lat: rand * 180 - rand * 180,
                                      lng: rand * 180 - rand * 180,
                                      device: device,
                                      checkins_count: rand(100)
      end
      device.permission_for(developer).update(privilege: "complete")
    end

    context "with no page param given" do
      it "fetches the most recent locations (up to 30 locations)" do
        get :index, params: params.merge(per_page: 30), format: "json"

        expect(response.header["X-Next-Page"]).to eq "2"
        expect(response.header["X-Current-Page"]).to eq "1"
        expect(response.header["X-Total-Entries"]).to eq device.locations.count.to_s
        expect(response.header["X-Per-Page"]).to eq "30"
        expect(res_hash[:locations].size).to eq 30
      end
    end

    context "with page param" do
      it "fetches the locations on that page if they exist" do
        page = 2
        get :index, params: params.merge(page: page), format: "json"

        expect(response.header["X-Current-Page"]).to eq page.to_s
        expect(response.header["X-Next-Page"]).to eq "null"
      end

      it "fetches the right amount of locations with per page provided" do
        page = 4
        get :index, params: params.merge(page: page, per_page: 5), format: "json"

        expect(res_hash[:locations].size).to eq 5
        expect(response.header["X-Next-Page"]).to eq "5"
        expect(response.header["X-Current-Page"]).to eq page.to_s
      end

      it "does not get any locations if page does not exist" do
        get :index, params: params.merge(page: 3), format: "json"

        expect(res_hash[:locations]).to eq []
      end
    end

    context "with near param" do
      it "returns locations near the lat lng provided" do
        coord_string = Location.first.lat.to_s + "," + Location.first.lng.to_s
        get :index, params: params.merge(near: coord_string), format: "json"

        expect(res_hash[:locations].first["lat"]).to eq Location.first.lat
      end
    end

    context "with type most visited param" do
      before do
        FactoryGirl.create :location, checkins_count: 100, lat: 10.0, lng: 10.0, device: device
      end

      it "returns the 10 most visited locations" do
        get :index, params: params.merge(type: "most_visited"), format: "json"

        expect(res_hash[:locations].size).to eq 10
        expect(res_hash[:locations].pluck("lat")).to include 10.0
        expect(res_hash[:locations].pluck("lng")).to include 10.0
      end
    end
  end
end
